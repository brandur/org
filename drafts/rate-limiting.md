## Rate Limiting Strategies

### Time Bucketed

### Leaky Bucket

Luckily, an algorithm exists that can take care of the problem of this sort of
jagged rate limiting called the [leaky bucket][leaky-bucket]. Its very
intuitive to understand by simply comparing it to its real-world namesake:
imagine a bucket partially filled with water and which has some fixed capacity
(τ). The bucket has a leak in the bottom where some amount of water is allowed
to escape at a constant rate (T). Whenever an action worthy of rate limiting
occurs, some amount of water flows into the bucket, with the amount being
proportional to the relative costliness of the action. If the amount of water
entering the bucket is greater than the amount leaving through the leak, the
bucket starts to fill. If at any point the bucket is so full that water that
should be added fills it past capacity, then the action that would have added
the water is blocked.

Any particular quota, be it per user or per IP, is represented by a single
bucket. A single controller determines the appropriate bucket to fill when some
kind of action is performed and another leaks water from all buckets.

A you can probably imagine, the leaky bucket produces a very smooth rate
limiting effect. A user can still exhaust their entire quota by filling their
entire bucket nearly instantaneously, but after realizing the erorr, they
should still have access to more quota fairly quickly as the leak starts to
drain the bucket instantly.

The leaky bucket is normally implemented using a background "leak" process that
looks for any buckets that need to be drained, and drains each one in turn.
This process will normally make a pass on each bucket on some pre-configured
period, the granularity of which also repesents the floor on the period of any
limit in the system.

## GCRA

[gcra]: https://en.wikipedia.org/wiki/Generic_cell_rate_algorithm
[leaky-bucket]: https://en.wikipedia.org/wiki/Leaky_bucket
