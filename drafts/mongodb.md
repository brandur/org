Operated a large Postgres installation, then moved to being a regular user of a
large MongoDB cluster.

They've heard the stories and imagine that using MongoDB is pretty bad. What
they don't expect is what I tell them next, "it's much worse than you think."

_M:I reference?_

## Non-issues

### Data Loss

I'll give them a pass; every early database has this problem.

### Bad Benchmarks

I'm willing to give them the benefit of the doubt here by applying Hanlon's
Razor: I think it's far more likely that the botched benchmarks were the result
of incompetence than malice.

## Problems

### No Transactions

What happens in a big MongoDB-based production system when a request that
commits multiple documents fails halfway through? Well, it's exactly what you
would think given a few moments to think about it: Mongo only guarantees
consistency within updates of a single document, so you're left with
inconsistent data.

In the optimal system, you have an automated process that attempts to identify
this class of failure and clean them up by reverting data to a consistent
state. In a real-world system, you almost certainly have a human operator that
dives in and _manually_ repairs that bad data. Remember that the process could
have been cut off between _any_ two Mongo commits, so you could be left with an
innumerable number of edge cases that are difficult to compensate for with an
automated repair system.

Serialization transactions are magic.

### No Atomicity

Mongo supports atomic operations at the document level. Despite what you might
read in their documentation, in a system anchored in the real world,
document-level atomic operations are about as useful as _no atomic operations_.
That's because any non-trivial computation is almost certainly going to operate
on multiple documents, and not having strong atomicity guarantees is going to
bring you into a world of contention, failure, and pain.

So how do you deal with this in a Mongo-based production system? _You implement
locking yourself_. Yes, you read that right. Instead of having your mature data
store take care of this tremendously difficult problem for you, you pull it
into your own almost certainly buggy application-level code. And don't think
for a minute that you're going to build in the incredibly sophisticated
optimistic locking features you get with any modern RDMS; no, to simplify the
complicated problem and save time, you're going to build a pessimistic locking
scheme. That means that simultaneous accesses on the same resource will block
on each other to modify data, and make your system fundamentally slower.

### No Constraints

### Analytics

## Non-solutions

### The Oplog is sure cool.

If you're tailing an oplog, you're communicating between components using
private implementation details. Your entire system becomes inherently fragile
because internal changes to how data is stored can take down everything else.

That's the easy and highly ideal answer. Perhaps worse yet, 

You should not be using the oplog except in very specialized storage-related
cases.

### But at least it's scalable right?

Junk data.

### Well, if nothing else, at least it's HA!

Even if a replica set is theoretically HA, it's never a disk failure on network
partitioning that takes you down [1]. It's MongoDB providing you with every footgun
under the sun.

I've seen easily as much downtime 

## Summary

If you're already on Mongo, it may be very difficult to migrate off of and
staying on it might be the right choice for your organization. I can relate.
But I would argue that using Mongo for a new system is _never_ the right
choice.

Do you need document-style storage (i.e. nested JSON structures)? You probably
don't, but if you really really do, you should use the `jsonb` type in Postgres
instead of Mongo. You'll get the flexibility that you're after [2], but also an
ACID-compliant system and the ability to introduce constraints [3].

Do you need incredible scalability that Postgres can't possibly provide? Unless
you're Google or Facebook, you probably don't, but if you really really do, you
should store your core data (users, apps, payment methods, servers, etc.) in
Postgres, and move those data sets that need super scalability out into
separate scalable systems _as late as you possibly can_. The chances are that
you'll never even get there, and if you do you may still have to deal with some
of the same problems that are listed here, but at least you'll have a stable
core.

## References

https://news.ycombinator.com/item?id=11857674

http://cryto.net/~joepie91/blog/2015/07/19/why-you-should-never-ever-ever-use-mongodb/

[1] Okay, this is embellished for dramatic effect. Sometimes a resource failure
    will take a system down, but in my experience, these incidents are dwarfed
    by those incited by user error.

[2] Although, this sort of flexibility may not be as good of an idea as you
    might think.

[3] In Postgres, try creating a `UNIQUE` index on a predicate that uses a JSON
    selector to query into a JSON document stored in a field. It works, and is
    incredibly cool.
