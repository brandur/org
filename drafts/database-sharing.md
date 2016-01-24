> For every complex problem there is an answer that is clear, simple, and
> wrong.
>
> &mdash; H. L. Mencken

Sharing a database between components is a technique where this concept is
especially relevant, but it may not be intuitve as to why that is. Engineers
who've been around the block would probably acknowledge this as a design smell,
but possibly without being able to articulate its precise problems.

We certainly know that the technique has a number of advantages:

1. **Easy:** No need for an API abstraction later or an interservice ACL model.
   Just pass around a connection string secret, do a little reverse engineering
   of code to learn how the schema is used, and you're done.
2. **Efficient:** SQL and/or direct queries is an incredibly powerful way of
   looking up data. A RESTful or RPC-style web API might not have anywhere near
   SQL's flexibility in terms of the variety of data available or ability to
   access data in bulk.
3. **Normalized:** Differentiated data stores inherently leads to at least some
   data having to be denormalized. With a single data store, everything is kept
   in one place and there's no risk of divergence of any kind.

Despite the obvious upsides, this is still a model that needs to be avoided in
the long run by any company that's building out an internal service-based
architecture. Let's take a look at a few of the problems that will eventually
start to fall out of it.

## Problems (#problems)

### Immutable Schema (#immutable-schema)

### Unstable APIs (#unstable-apis)

Stability.

Password V1 -- V2.

### Unclear Ownership (#ownership)

Tragedy of the commons.

Operations.

### Complex Failover (#failover)

### Resource Contention (#contention)

Everything from number of connections allowed to delay in WAL application.

## What You Should Do Instead (#alternatives)

## Solutions (#solutions)
