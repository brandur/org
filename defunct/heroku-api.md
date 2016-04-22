## Problems With V2 (#v2)

### Inconsistent Everything

### Bloated Serializations

### No Contract

### No Description

### Steady Degradation (#steady-degradation)

Even a good samaritan developer who tried their utmost to build new endpoints
correctly according to the best possible practices had no clear way forward.
Even recently built endpoints disagreed on basic convention, and there was no
way to tell if one was preferred over the other.

## Development (#development)

### Design Decisions

1. Pitch.
2. Discuss.
3. Engrave and move on.

This led to lengthy discussions over design choices that probably wouldn't make
too much of a practical difference either way. For example:

* Versioning in the `Accept` header versus in the URL path.

But this invested time had a major advantage: it got all stakeholders onto the
same page and allowed consensus to emerge to the point where the issue could be
put to rest permanently. And if it ever reared its head at some point in the
future, we had an extensive papertrail that we could use as reference for
newcomers to the discussion. The initial overhead led to countless hours of
repeated debate being saved down the road.

### Hypermedia

### The Schema

Leverage it as much as possible:

* Generate documentation.
* Generate SDKs.
* Acceptance tests verifying responses.
* Parameter input validation for requests.

### Implemetation

V3 modules.

## Legacy

### Dashboard

## Successes

### Establishment of Convention

## Failures

### Internal Concerns

* Bulk. (GraphQL?)
* Stable pagination.

### Endpoint Stability

### Foster the Community

Only the most devoted fan of a company will try to build against an API in a
vacuum.

Docs and examples.

### Open Source

If you release an open Source project, make sure you can support it.

Our major failures here were Heroics and Schematic, which were both promptly
dropped by their authors as soon as they were released.

### HTTP Dogma

As is dictated by the API community as righteous best practice, we tried to
follow the HTTP spec was closely as possible when designing the new API. For
example, we'd make sure to use `PATCH` instead of `PUT` for non-idempotent
updates, or that everything you might see in the URL bar is a proper resource
(which led to conventions like `/authorizations/:id/actions/regenerate-tokens`
instead of just `/authorizations/:id/regenerate-tokens`). In retrospect, I'm
glad that we got it done, but I also don't consider the work an absolute
necessity. Users just don't care that much.

### Range Pagination
