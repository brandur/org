A common pattern used in systems that rely on Postgres-like database systems is to run a single primary that's used for production operations, and to stand-up a number of followers which may be used for readonly queries to take load off of the primary. Keeping one of those followers reserved for more expensive analytical-type queries is also not unusual in that this is often the easiest route for various stakeholders to generate reports on a variety of business data that might interest them. For example, a marketing team might want easy access to the number of new signups that occurred over the last day, or the number of users that have been active in the last year.

This approach is a powerful and fairly lightweight system for keeping load off of the primary, but still allowing easy access to data for analytical purposes in very close to real-time. What might not be obvious though, is how under the right conditions such a system can produce feedback to a primary and lead to severe impact on a production environment.

In [Postgres Job Queues & Failure By MVCC](/postgres-queues) I described how a long-lived transaction can negatively affect the performance of a hot table thanks to bloat in its index. Tables that are susceptible to this problem are those that (1) are seeing frequent deletions which leads the accumulation of invisible rows that can't be VACUUMed until the transaction ends, and (2) where frequent lookups are occurring. Those lookups must scan over any dead rows that match the requested predicate and fetch each one from the heap as their visibility is checked. Furthermore, because an index stores only minimal visibility information, this work is thrown out between each lookup, and subsequent queries must repeat the work all over again.

While it may be somewhat intuitive that a long-lived transaction on the primary can affect operations there, what might not be as obvious (and what I glossed over in the last article) is how one on a follower can lead to the same effect. To fully understand the effect, we'll have to dive into the various mechanisms that Postgres provides to resolve query conflicts between the master and its followers.

## The WAL

A key fundamental to understanding some of the interactions between a primary and its followers in Postgres is knowing a few basics about the Postgres write-ahead log (WAL). The WAL is an important Postgres mechanic for guaranteeing data integrity within the system in that rather than flushing entire page files to disk on every write, those changes can instead be grouped and written sequentially as part of the WAL. In the event of a system failure, whatever on-disk representations were left over can be re-used and the WAL replayed against them to rebuild an accurate pre-crash representation of the data.

The WAL is also very important in that it's how a primary tells its followers about changes in the system. Postgres can either send WAL via [streaming replication]() or by [archived WAL files](), which the follower receives and commits to its own system to keep itself up to date. Archiving in particular is a very neat mechanism in that it can be combined with software like [wal-e]() to archive WAL to S3, thus keeping the I/O load on a primary database stable no matter how many followers it may have to support because they're all reading their WAL directly from S3 instead of the primary's disk.

## Query Conflicts and Cancellation

As described in [Handling Query Conflicts]() in the Postgres manual, there are a variety of situations where queries that are occurring on a follower may conflict with activity on the primary. In some cases these may be _hard conflicts_ in the sense that Postgres must step in to resolve them.

The best example of this might be if a `DROP TABLE` occurs on the primary for a table that's currently being queried on a follower. If this situation had happened directly on the primary, it could simply delay the table drop until the query resolved itself, but because it's occurring on a follower, the only equivalent possibility would be to delay application of the WAL until the query resolved.

Delaying WAL application has some undesirable side effects, namely that the follower could fall very far behind the primary's state. It could also lead to the accumulation of WAL files which may eventually fill a follower's disk.

The primary mechanism that Postgres provides to resolve these types of conflicts is _query cancellation_. The settings `max_standby_archive_delay` and `max_standby_streaming_delay` dictate the maximum amount of time that a query is allowed to delay WAL replication before Posgres cancels it forcibly. This is usually a nice compromise in that it allows a grace period for conflicting queries on followers to resolve themselves, but also provides a way to guarantee a constraint on the maximum drift between a primary and its followers.

But query cancellation is not always convenient. If a user wants to run a relatively expensive and long-running operation on a follower, say a database backup for example, it may be difficult for it to ever complete it there's enough activity (and by extension a fairly steady stream of WAL) happening on the primary.

If query cancellation is found to be overly disruptive, Postgres provides a few other useful possibilities. `hot_standby_feedback` is one that allows followers to report the state of their ongoing queries back to the primary so that it will prevent VACUUMs from removing any rows that may still be visible to them just as if those queries were running on the primary. This setting is particularly useful because the most common reason for conflict between primaries and followers is _early cleanup_. This is the effect that occurs when a primary reaps rows that are no longer visible to any of its ongoing queries, but by doing so leaves a large discrepancy between itself and any followers that may need to keep those rows around to satisfy their open queries.

```
               WAL
        +----------------+
        |                |
        |                v
   +----+----+      +---------+
   |         |      |         |
   |         |      |         |
   | Primary |      | Standby |
   |         |      |         |
   |         |      |         |
   +----+----+      +----+----+
        ^                |
        |                |
        +----------------+
           Oldest xmin
```

## Production Impact

At some point in the past while building out their product, the Heroku Postgres team found that query cancellation was problematic for their operations. Kicking off a database backup on a follower requires that a long-lived snapshot be opened for the entirety of the time that it takes to produce a backup, and for larger databases query cancellation was kicking in and canceling backups before they could ever complete. They tried to relax the the cancellation policy by increasing the maximum standby delay, but were foiled once again whereby high-churn databases were able to fill disks on followers with unapplied WAL while waiting for their queries to resolve. They compromised by disabling cancellation but enabling `hot_standby_feedback`. This allowed followers to report their transactions to their primary to prevent early cleanup and minimize the amount of WAL produced during a long running follower query.

While working nicely in most cases, the inadvertent side effect to this decision was to open the possibility of table bloat resulting from follower feedback to impact the operation of hot tables on the primary (as described above). Although somewhat intuitive after all the background information is known, this can be an extremely surprising effect if it isn't (and as you may have guessed, was to us the first time we observed it).

## The Mechanics of `hot_standby_feedback`

The precise mechanics of how `hot_standby_feedback` actually works are pretty interesting and surprisingly digestible once you dive into the Postgres source, so let's dig into them a bit here. Note that the Postgres is still under active development, and as such made of these code snippets are probably going to be outdated in short order, but the overall concept is likely to be pretty stable.

The file we're interested in here is [walreceiver.c](). When the Postgres startup process determines that it's ready to start streaming, it tells the postmaster (the Postgres master process) to start up the walreceiver. The walreceiver connects to its configured primary and starts receiving WAL from it, which it writes to disk. After successfully receiving a new segment, it updates a variable in memory that it shares with the startup process to inform it how far it can proceed with WAL replay.

The first interesting walreceiver function is is the process' main loop `WalReceiverMain` which connects to the primary and loops continually by receiving and processing new messages:

``` c
/* Main entry point for walreceiver process */
void
WalReceiverMain(void)
{
    ...

	for (;;)
	{
        ...

        /* Wait a while for data to arrive */
        len = walrcv_receive(NAPTIME_PER_CYCLE, &buf);
        if (len != 0)
        {
            ...

            XLogWalRcvProcessMsg(buf[0], &buf[1], len - 1);

            ...
        }

        ...
    }

    ...
}
```

`XLogWalRcvProcessMsg` as seen above calls down to `XLogWalRcvWrite` which then calls down to `XLogWalRcvFlush`. It's here that the walreceiver may take the opportunity to report back to the primary:

``` c
/*
 * Flush the log to disk.
 *
 * If we're in the midst of dying, it's unwise to do anything that might throw
 * an error, so we skip sending a reply in that case.
 */
static void
XLogWalRcvFlush(bool dying)
{
    ...

    /* Also let the master know that we made some progress */
    if (!dying)
    {
        XLogWalRcvSendReply(false, false);
        XLogWalRcvSendHSFeedback(false);
    }

    ...
}
```

`XLogWalRcvSendReply` sends a basic reply the server's WAL message which includes a few vitals like the follower's new position in the log. Note that this doesn't always trigger a reply as Postgres only sends feedback at regular intervals to avoid unnecessary I/O.

But it's the following call to `XLogWalRcvSendHSFeedback` that we're really interested in. This is the function responsible for sending a separate message back to the server containing the status of the follower's currently running queries (and like its companion `XLogWalRcvSendReply`, it will only do so on a certain interval):

``` c
/*
 * Send hot standby feedback message to primary, plus the current time,
 * in case they don't have a watch.
 *
 * If the user disables feedback, send one final message to tell sender
 * to forget about the xmin on this standby.
 */
static void
XLogWalRcvSendHSFeedback(bool immed)
{
    ....

	/*
	 * Make the expensive call to get the oldest xmin once we are certain
	 * everything else has been checked.
	 */
	if (hot_standby_feedback)
		xmin = GetOldestXmin(NULL, false);
	else
		xmin = InvalidTransactionId;

    ...

	pq_sendint(&reply_message, xmin, 4);

    ...
}
```

You may notice that rather than reporting on individual queries, Postgres is only sending a single integer back to the primary (`xmin`). Every transaction in Postgres that modifies data is assigned a transaction ID (`xid`) and every row of data tracks the bounds of its own visibility by remembering the bounds of the transaction that created it (stored as the hidden field `xmin`) and the transaction that deleted it (`max`; `NULL` if the row has never been deleted). Readonly queries in Postgres may not increment `xid`, but they do remember the current `xid` so that they can resolve the visibility of any tuple of data that they read.

Here `GetOldestXmin` is looking up the `xid` of the oldest transaction that was running when any current transaction was started. Reporting this one value back to the primary is enough to give it a lower bound on what data it's allowed to prune with a VACUUM.

## Alternative Approaches

Unless a fairly aggressive cancellation policy is in place, we can see based on the above that there is always going to be some danger of a follower producing feedback that affects the operation of its primary. It's worth considering a couple alternatives to the classic model of a primary with an analytics follower described above.

### Forks

A fairly simple alternative model might to move to one where new followers of the primary are brought online on a periodic schedule and then unfollowed, used for purposes of running analytics against a fairly fresh data set or producing a base backup, and then recycled as a new follower is brought online and unfollowed. This type of "forking" model is well supported by Postgres, which can use the latest file system level backup combined with the most recent WAL to bring a new follower online cheaply. It also has the advantage of being perfectly safe compared to the same system based on followers, with the machinery used to create the periodic forks must be maintained.

### Logical Streaming

A system built on top of a shared internal database might be an appropriately cheap solution for a smaller organization, but should be re-evaluated as soon as its used starts to become more widespread. Aside from the possible production issues outlined above, sharing a database across components can result in other types of problems as well: changing the database's schema becomes difficult because there's no saying what it might break, and any kin of failover becomes a much more complicated operation.

An organization might consider a _logical streaming_ approach instead whereby a component streams the logical changes that are occurring within it over a salable bus like Kafka or Kinesis in a well-defined format that's been designed and documented. This puts a much stronger contract in-place between the source component and it consumers which will be much less likely to fall apart over the long run. LinkedIn has produced a good article describing this idea in more detail entitled simply ["The Log"](http://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying).

## Summary

Postgres has various built-in mechanisms to help avoid or resolve query conflicts between a primary database and its followers. Some of these, like `hot_standby_feedback`, are able to produce back pressure on the primary by preventing it from cleaning up rows that might otherwise be pruned by a VACUUM. This is effective for preventing certain types of conflict, but may also lead to a follower being able to cause undesirable degradation in a production system.
