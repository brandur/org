> Web APIs were inconvenient, thought Joe. Fetching an up-to-date e-mail address of a single user required provisioning an API key provisioned with special privileges for acessing sensitive data, a process that involved following instructions in a long document. Even once you had that, getting the up-to-date e-mail addresses of a thousand different users generally required a new request for each one &mdash; an incredibly inefficient process! In SQL, that was all possible given only a single query.
>
> Pulling up a console, he keyed an operator command that would get him the credentials for the system's master database. Then, opening the code of his own service, he entered a few lines that would allow it to connect to that database and query against it directly. He tenatively pushed the change up to a staging environment to see what would happen. Success! This little trick was going to save him hours worth of work. It was amazing that no one had thought of it before.
>
> Things moved quickly from there. A few months later, he'd fully baked that foreign database connection into his service and was using it for dozens of lookups. The company's entire dataset was available at his fingertips, and accessing any of it was just a single SQL query away. The setup was robustly engineered too; by bootstrapping his project with a second database schema, he'd been able to build out a test suite that verified operation based on the contents of the other database. He was a rockstar.
>
> Two years later, a variety of interesting failures, cross-team contention during development, and bad production incidents eventually led to the decision to reverse Joe's changes. Adherence to the bad design had ballooned to the extent that doing so was only possible at considerable expense; the project would be a multi-engineer effort over two full quarters.

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
