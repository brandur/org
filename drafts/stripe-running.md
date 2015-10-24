One pleasant surprise of Stripe's internal culture was the existence of a
number of a recreational clubs (mostly manifested as internal Slack channels)
-- and specifically one for running. At least some part of the group would
assemble regularly and go out and tackle runs around San Francisco's Mission
district where the Stripe office is located.

By the time I joined, the club already had a couple of well-established
traditional loops which included some real gargantuans. Probably the most
notable is the (internally) renowned "Triple Peaks", a journey south from the
office, up Bernal Heights, west through Glen Canyon Park, and a final ascent up
Twin Peaks. My usual routes around Heroku's office in SOMA included pretty
healthy total distances, but nowhere near this level of ascents or variation in
terrain.

!fig src="/assets/stripe-running/triple-peaks.png" caption="The daunting Tripe Peaks run in San Francisco."

## Analysis

Between the new social pressure and the new available routes, over the last
month I've certainly _felt_ like I was running more, but it would be nice to
know for sure. Let's try to use Postgres to crunch some data and get a
definitive answer.

In order to do a comparison, I want to run the same query that aggregates my
distance from two different points in time: once for my time here and once for
my previous life. A great fit for this operation is a Postgres prepared
statement which through the use of the `PREPARE` command creates a server-side
object that's parsed and pre-analyzed for execution. As soon as an `EXECUTE` is
run against it, the planner comes into play and the statement gets run. I've
personally always tangentially associated prepared statements with heavy
enterprise DB libraries and have been relunctant to use them, but we'll show
here just how simple their syntax is and thus easily suitable for use in
one-off query situations.

I'm using a database created for my [Black Swan project][black-swan], which
periodically scrapes my social media services. I routinely log all my runs with
Strava, and the data here is being pulled from their API specifically.

Here we define our prepared statement named `running_totals` with a time
parameter indicating the day we want to start measuring from and a duration (or
`interval` in Postgres parlance) that specifies how far to go back in time:

``` sql
PREPARE running_totals AS
    SELECT sum((metadata -> 'distance')::decimal) AS distance,
        sum((metadata -> 'total_elevation_gain')::decimal) AS elevation
    FROM events
    WHERE type = 'strava'
        AND metadata -> 'type' = 'Run'
        AND date_trunc('day', occurred_at) <= date_trunc('day', $1::timestamptz)
        AND date_trunc('day', occurred_at) >= date_trunc('day', $1::timestamptz)
            - $2::interval;
```

You'll notice here that I'll be type casting the parameter with `::timestamptz`
and `::interval` so that I can send in strings as input. Postgres has an
amazing ability to cast loosely formatted strings like `September 9, 2015` and
`30 days` into concrete times and durations that we can work with in our
calculations.

Before Stripe I worked at Heroku. For this period, I'll measure backwards from
the date of my last run while working there:

``` sql
# EXECUTE running_totals('September 9, 2015', '30 days');
 distance | elevation
----------+-----------
 113854.1 |       0.0
```

For Stripe, I'll measure from today given that I've only been at the company
for roughly a month:

``` sql
# EXECUTE running_totals('October 22, 2015', '30 days');
 distance | elevation
----------+-----------
 181319.3 |    4468.6
```

An incredible difference of 173 km vs 114 km, or an almost 50% increase! The
real win though is in elevation where I've managed to accumulate 4.5 km of
vertical gain in 30 days. This represents my graduation from flat runs along
San Francisco's waterfront to the hilly regions closer to Stripe.

[black-swan]: https://github.com/brandur/blackswan
