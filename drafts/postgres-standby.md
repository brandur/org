A common pattern used in systems that rely on Postgres-like database systems is to run a single primary that's used for production operations, and to stand-up a number of standby servers which may be used for readonly queries to help distribute the load. Keeping one of those standby servers reserved for more expensive analytical-type queries is also not unusual in that this is often the easiest (or only) route for stakeholders to generate rich reports on a variety of business data that might interest them. For example, a marketing team might want easy access to the number of new signups that occurred over the last day, or the number of users that have been active in the last year.

This approach is a powerful and fairly lightweight system for keeping load off of the primary, but still allowing easy access to data for analytical purposes in very close to real-time. What might not be obvious though, is how under the right conditions such a system can produce feedback to a primary and lead to severe impact on a production environment.

In [Postgres Job Queues & Failure By MVCC](/postgres-queues) I described how a long-lived transaction can negatively affect the performance of a hot table thanks to bloat in its index. Tables that are susceptible to this problem are those that (1) are seeing frequent deletions which leads the accumulation of invisible rows that can't be VACUUMed until the transaction ends, and (2) where frequent lookups are occurring. Those lookups must scan over any dead rows that match the requested predicate and fetch each one from the heap as their visibility is checked. Furthermore, because an index stores only minimal visibility information, this work is thrown out between each lookup, and subsequent queries must repeat it all over again.

While it may be somewhat intuitive that a long-lived transaction on the primary can affect operations there, what might not be as obvious (and what I glossed over in the last article) is how one on a standby can lead to the same effect. To fully understand it, we'll have to dive into the various mechanisms that Postgres provides to resolve query conflicts between the master and its standby servers.

## The WAL (#wal)

Before we do that though, let's revisit a few basics of the Postgres write-ahead log (WAL). The WAL is an important mechanic for guaranteeing data integrity while simultaneously improving performance within Postgres in that rather than flushing entire page files to disk on every write, those changes can instead be grouped and written sequentially as part of the WAL. In the event of a system failure, whatever on-disk representations were left over can be re-used and the WAL replayed against them to rebuild an accurate pre-crash representation of the data.

The WAL is also a critical piece in how a primary tells its standby servers about changes in the system. Postgres can either send WAL via [streaming replication](http://www.postgresql.org/docs/current/static/warm-standby.html#STREAMING-REPLICATION) or by [archived WAL files](http://www.postgresql.org/docs/current/static/continuous-archiving.html#BACKUP-ARCHIVING-WAL), which each standby receives and commits to its own system to keep itself up to date. Archiving in particular is a very powerful mechanism in that it can be combined with software like [wal-e](https://github.com/wal-e/wal-e) to archive WAL to S3, thus keeping the I/O load on a primary database stable regardless of the number of standby servers in operation because each is reading its WAL directly from S3 instead of the primary's disk.

## Query Conflicts and Cancellation (#conflicts)

As described in [Handling Query Conflicts](http://www.postgresql.org/docs/current/static/hot-standby.html#HOT-STANDBY-CONFLICT) in the Postgres manual, there are a variety of situations where queries that are occurring on a standby may conflict with activity on the primary. In some cases these may be _hard conflicts_ in the sense that Postgres must step in to resolve them.

The most intuitive example of this might be if a `DROP TABLE` occurs on the primary for a table that's currently being queried on a standby. If this situation had happened directly on the primary, it could simply delay the table drop until the query resolved itself, but because it's occurring on a standby, the only equivalent possibility would be to delay application of the WAL until the query resolved.

Delaying WAL application isn't harmful in moderation, but can have undesirable side effects. For example, it could cause a standby to fall very far behind the primary's state. It could also lead to the accumulation of WAL files which may eventually fill a standby's disk.

The primary mechanism that Postgres provides to resolve these types of conflicts is _query cancellation_. The settings `max_standby_archive_delay` and `max_standby_streaming_delay` dictate the maximum amount of time that a query is allowed to delay WAL replication before Posgres cancels it forcibly. This is usually a nice compromise in that it allows a grace period for conflicting queries on standby servers to resolve themselves, but also provides a way to guarantee a constraint on the maximum drift between a primary and its standby servers.

But query cancellation is not always convenient. If a user wants to run an expensive long-running operation on a standby, say a database backup for example, it may be difficult for it to ever complete if there's enough activity (and by extension a fairly steady stream of WAL) happening on the primary. The WAL delay will trigger a cancellation every time.

The compensate for this possibility, Postgres offers a few other useful alternatives to cancellation. `hot_standby_feedback` is one that allows standby servers to report the state of their ongoing queries back to the primary so that it will prevent VACUUMs from removing any rows that may still be visible to them just as if those queries were running on the primary. This setting is particularly useful because the most common reason for conflict between primaries and standby servers is _early cleanup_. This occurs when a primary reaps rows that are no longer visible to any of its ongoing queries, but by doing so leaves a large discrepancy between itself and any standby servers that may need to keep those rows around to satisfy their open queries (and once again, stalling the application of WAL).

A simplified illustration might look a little like the primary streaming WAL to a standby, and that standby in return reporting its query status back to the primary:

``` monodraw
                                               
         ┌────────────WAL────────────┐         
         │                           │         
         │                           ▼         
┌─────────────────┐         ┌─────────────────┐
│                 │█        │                 │
│                 │█        │                 │
│     Primary     │█        │     Standby     │
│                 │█        │                 │
│                 │█        │                 │
└─────────────────┘█        └─────────────────┘
 ████████▲██████████                 │         
         │                           │         
         └────────Oldest xmin────────┘         
                                               
```

## Production Impact (#production-impact)

At some point in the past while building out their product, the Heroku Postgres team found that query cancellation was problematic for their service: kicking off a database backup on a standby requires that a long-lived snapshot be opened for the entirety of the time that it takes to produce a backup, and for larger databases query cancellation was kicking in and canceling backups before they could complete. They tried to relax the the cancellation policy by increasing the maximum standby delay, but were foiled once again whereby high-churn databases were able to fill disks on standby servers with unapplied WAL while waiting for their queries to resolve. In the end, they compromised by disabling cancellation but enabling `hot_standby_feedback`, which allowed standby servers to report queries to their primary and thereby prevent early cleanup and minimize the amount of WAL produced.

While working nicely in most cases, the inadvertent side effect to this decision was to open the possibility of table bloat resulting from standby feedback to impact the operation of hot tables on the primary (as described above). Although somewhat intuitive after all the background information is known, this can be an extremely surprising effect if it isn't. It took us a few incidents in production before we finally figured out exactly what was going on.

## The Mechanics of `hot_standby_feedback` (#hot-standby-feedback)

The implementation of `hot_standby_feedback` is pretty interesting and quite digestible (which was a pleasant surprise for me), so let's dig into the Postgres source a little bit. Note that the Postgres is still under active development, and as such made of these code snippets are probably going to be outdated in short order, but the overall concept is likely to be pretty stable for some time to come.

The file we're interested in here is [walreceiver.c](https://github.com/postgres/postgres/blob/55c0da38be611899ae6d185b72b5ffcadc9d78c9/src/backend/replication/walreceiver.c). When the Postgres startup process determines that it's ready to start streaming, it tells the postmaster (the Postgres master process) to start up the walreceiver. The walreceiver connects to its configured primary and starts receiving WAL from it, which it writes to disk. After successfully receiving a new segment, it updates a variable in memory that it shares with the startup process to inform it how far it can proceed with WAL replay.

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

`XLogWalRcvProcessMsg` calls down to `XLogWalRcvWrite` which then calls `XLogWalRcvFlush`. It's here that the walreceiver may take the opportunity to report back to the primary:

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

`XLogWalRcvSendReply` sends a basic reply the server's WAL message which includes a few vitals like the standby's new position in the log. Note that this doesn't always trigger a reply as Postgres only sends feedback at regular intervals to avoid unnecessary network traffic.

But it's the following call to `XLogWalRcvSendHSFeedback` that we're really interested in. This is the function responsible for sending a separate message back to the server containing the status of the standby's currently running queries (and like its companion `XLogWalRcvSendReply`, it will only do so on a certain interval):

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

You may notice that rather than reporting on individual queries, Postgres is only sending a single integer back to the primary (`xmin`). Every transaction in Postgres that modifies data is assigned a transaction ID (`xid`) and every row of data tracks the bounds of its own visibility by remembering the bounds of the transaction that created it (stored as the hidden field `xmin`) and the transaction that deleted it (`xmax`; `NULL` if the row has never been deleted). Readonly queries in Postgres may not increment `xid`, but they do remember the current `xid` so that they can resolve the visibility of any data that they read.

Here `GetOldestXmin` is looking up the `xid` of the oldest transaction that was running when any current transaction was started. Reporting this one value back to the primary is enough to give it a lower bound on what data it's allowed to prune with a VACUUM.

## Alternative Approaches (#alternatives)

Unless an aggressive cancellation policy is in place, there is always going to be the danger of a standby either (1) producing feedback that affects its primary, or (2) leaving itself in a degraded state (by falling behind on WAL). To avoid these cases completely, it may be worth considering a couple alternatives to the classic model of a primary with an analytics standby.

### Forks (#forks)

A reasonably simple alternative model might to move to one where new standby servers of the primary are brought online on a periodic schedule, detached from the primary, used for a short tiem while their data is reasonably fresh, and then recycled as a new standby servers are activated. This type of "forking" model is well supported by Postgres, which can use the latest file system level backup combined with the most recent WAL to bring a new standby online cheaply. It also has the advantage of being perfectly safe compared to the same system based on standby servers, with the only disadvantages being the possibility of slightly outdated data and that the machinery used to create the forks requiring some development and maintenance.

### Application-level Streaming (#application-level-streaming)

A system built on top of a shared internal database might be an appropriately cheap solution for a smaller organization, but should be re-evaluated as soon as its used starts to become more widespread. Aside from the possible production issues outlined above, sharing a database across components can result in other types of problems as well: changing the database's schema becomes difficult because there's no saying who or what it might break, and any kind of failover becomes a much more complicated operation.

An organization might consider a _application-level streaming_ approach instead whereby a component streams the logical changes that are occurring within it over a salable bus like Kafka or Kinesis in a well-defined format that's been designed and documented. This puts a much stronger contract in-place between the source component and it consumers which will be much less likely to fall apart over the long run. LinkedIn has produced a good article describing this idea in more detail entitled ["The Log"](http://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying).

## Summary (#summary)

Postgres has various built-in mechanisms to help avoid or resolve query conflicts between a primary database and its standby servers. Some of these, like `hot_standby_feedback`, are able to produce back pressure on the primary by preventing it from cleaning up rows that might otherwise be pruned by a VACUUM. This is effective for preventing certain types of conflict, but may also lead to a standby being able to cause undesirable degradation in a production system.
