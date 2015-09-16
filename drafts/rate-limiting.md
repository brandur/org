Rate limiting 

## Time Bucketed (#time-bucketed)

A very simple rate limiting implementation is to simply bucket the remaining
limit for a certain amount of time. Start a bucket when the first action comes
in, decrement its value as more actions appear, and expire the bucket after the
configured rate limiting period. The pseudo-code might look like the following:

``` ruby
# 5000 allowed actions per hour
RATE_BURST  = 5000
RATE_PERIOD = 1.hour

def rate_limit?(bucket)
  if !bucket.exists?
    bucket.set_value(RATE_BURST)
    bucket.set_ttl(RATE_PERIOD)
  end

  if bucket.value > 0
    bucket.decrement
    true
  else
    false
  end
end
```

The Redis `SETEX` command makes this trivial to implement; just set a key
containing the remaining limit with the appropriate expiry and let Redis take
care of clean-up.

### Downsides (#time-bucketed-downsides)

This method can be somewhat unforgiving for users because it allows a buggy or
rogue script to burn an account's entire rate limit immediately, and force them
to wait for the next reset event to be able to get access back.

By the same principle, the algorithm can be dangerous to the server as well.
Consider an antisocial script that can make enough concurrent requests that it
can exhaust its rate limit in short order and which is regularly overlimit.
Once an hour as the limit resets, the script bombards the server with a new
series of requests until its rate is exhausted. In this scenario the server
always needs enough extra capacity to handle these short intense bursts and
which will go to waste during the rest of the hour. This wouldn't be the case
if we could find an algorithm that would force these requests to be more evenly
spaced out.

GitHub's API is one such service that implements this naive algorithm, and I
can use it to easily demonstrate this problem:

``` sh
```

And now I'm locked out for the next hour:

``` sh
$ curl --silent --head -i -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/users/brandur | grep RateLimit-Reset
X-RateLimit-Reset: 1442423816

$ RESET=1442423816 ruby -e 'puts "%.0f minute(s) before reset" % \
    ((Time.at(ENV["RESET"].to_i) - Time.now) / 60)'
29 minute(s) before reset
```

## Leaky Bucket (#leaky-bucket)

Luckily, an algorithm exists that can take care of the problem of this sort of
jagged rate limiting called the [leaky bucket][leaky-bucket]. It's very
intuitive to understand by simply comparing it to its real-world namesake:
imagine a bucket partially filled with water and which has some fixed capacity
(τ). The bucket has a leak so that some amount of water is escaping at a
constant rate (T). Whenever an action that should be rate limited occurs, some
amount of water flows into the bucket, with the amount being proportional to
its relative costliness. If the amount of water entering the bucket is greater
than the amount leaving through the leak, the bucket starts to fill. Actions
are disallowed if the bucket is full.

``` monodraw
          ***      User                           
      │   ***    actions                          
      │            add                            
      │          "water"                          
      │                                           
      │                                           
═╗    ▼   ***        ╔═       ▲                   
 ║        ***        ║        │                   
 ║                   ║        │                   
 ║                   ║   τ = Bucket               
 ║                   ║    capacity                
 ║*******************║        │                   
 ║*******************║        │                   
 ║*******************║        │                   
 ╚════════╗*╔════════╝        ▼                   
          ║*║                                     
         ═╝*╚═                                    
           *                 ┌──────────────────┐ 
      │    *                 │                  │░
      │    *    Constant     │   LEAKY BUCKET   │░
      │    *    drip out     │                  │░
      ▼    *                 └──────────────────┘░
           *                  ░░░░░░░░░░░░░░░░░░░░
```

The leaky bucket produces a very smooth rate limiting effect. A user can still
exhaust their entire quota by filling their entire bucket nearly
instantaneously, but after realizing the error, they should still have access
to more quota fairly quickly as the leak starts to drain the bucket
immediately.

The leaky bucket is normally implemented using a background process that
simulates a leak. It looks for any active buckets that need to be drained, and
drains each one in turn. In Redis, this might look like a hash that groups all
buckets under a type of rate limit and which is dripped by iterating each key
and decrementing it.

### Downsides (#leaky-bucket-downsides)

The naive leaky bucket's greatness weakness is its "drip" process. If it goes
offline or gets to a capacity limit where it can't drip all the buckets that
need to be dripped, then new incoming requests might be limited incorrectly.
There are a number of strategies to help avoid this danger, but if we could
build an algorithm without a drip, it would be fundamentally more stable.

## GCRA (#gcra)

This leads us to the leaky bucket variant called ["Generic Cell Rate
Algorithm"][gcra] (GCRA).

[gcra]: https://en.wikipedia.org/wiki/Generic_cell_rate_algorithm
[leaky-bucket]: https://en.wikipedia.org/wiki/Leaky_bucket
