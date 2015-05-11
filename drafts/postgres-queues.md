You get a page and open your laptop. Your job queue has spiked to 10,000 jobs and is continuing to grow. The bloated queue means that internal components are not getting updates that are critical to the health of the platform. You start to investigate. Activity elsewhere looks normal and jobs are being worked in a timely manner. Everything else looks normal. After close to an hour feeling around the system you notice a transaction that another team has opened for analytical purposes on one of your database followers. You promptly send it a SIGINT. The queue's backlog falls off a cliff and everything returns to normal nearly instantly.

Long running databases transactions appear to be the culprit here, but how exactly can they have such a significant impact on a database table? And so quickly no less? Furthermore, the transaction wasn't even running on the master database, but was rather ongoing on a follower.

The figure blow shows a simulation of the effect. With a relatively high rate of churn through the jobs table (roughly 50 jobs a second here), the effect can be reproduced quite quickly, and once it starts to manifest (15 minutes in), it worsens very quickly without hope of recovery.

<figure>
  <p><img src="/assets/postgres-queues/pre-queue-count.png"></p>
  <figcaption>Oldest transaction in seconds on the left. Queue count on the right. One hour in, we're close to 60k jobs.</figcaption>
</figure>

## Why Put a Job Queue in Postgres?

Your first question may be: why put a job queue in Postgres? It may be far from the use case that databases are designed for, but storing jobs in a database allows a program to take advantage of its transactional consistency; when an operation fails and rolls back, the inject job rolls back with it. Postgres transactional isolation also keeps jobs invisible to workers until their transactions commit and are ready to be worked.

As we'll see below, there are very good reasons not to use your database as a job queue, but by making sure to observe a few key points system metrics (oldest running transaction first and foremost), an app can get a long way before getting off of this system.

## Building a Test Bench

We originally noticed this problem in production, but the first step for us to be able to check any potentials solutions that we come up with is to be able to reliably reproduce it in a controlled environment. For this purpose, we wrote the [que-degradation-test](https://github.com/brandur/que-degradation-test), which is a simple program with three processes:

* A job producer.
* A job worker.
* A "longrunner" that starts a transaction and then sits idle in it.

As hoped, the program was easily able to reproduce the problem and in a reliable way. All the charts in this article are from test data produced by it.

## Slow Lock Time

The first step into figuring out exactly what's going wrong is to find out what exactly about the long running transaction is slowing the job queue down. By looking around at a few queue metrics, we quickly find a promising candidate. During stable operation, a worker locking a job to make sure that it can be worked exclusively takes on the order of < 0.01 seconds. As we can see in the figure below though, as the oldest transaction gets older, this lock time escalates quickly until it reaches 0.1 s and above. That's probably more time than it takes to work your jobs. It makes sense conceptually too &mdash; as the difficulty to lock a job increases, workers can get through fewer of them in the same amount of time, and eventually fewer jobs are worked than are being produced.

<figure>
  <p><img src="/assets/postgres-queues/pre-lock-time.png"></p>
  <figcaption>Lock time.</figcaption>
</figure>

### Locking Algorithms

We'd originally suspected QC's relatively inefficient locking mechanism to be the culprit, and so moved our implementation over to Que. To our chagrin, we found that the problem still existed there as well, even if its better overall performance did seem to help stave it off for a little bit longer. We'll be examining Que in detail here, but it's worth nothing that both of these systems are suspectible to the same root problem.

The first step was to inspect the locking algorithm itself and make sure that there were no immediately obvious red flags that would explain the performance fallout. [Inspecting Que's source code](https://github.com/chanks/que/blob/f95aec38a48a86d1b4c82297bc5ed9c88bb600d6/lib/que/sql.rb), we see that it locks a job like so:

``` sql
WITH RECURSIVE job AS (
  SELECT (j).*, pg_try_advisory_lock((j).job_id) AS locked
  FROM (
    SELECT j
    FROM que_jobs AS j
    WHERE queue = $1::text
    AND run_at <= now()
    ORDER BY priority, run_at, job_id
    LIMIT 1
  ) AS t1
  UNION ALL (
    SELECT (j).*, pg_try_advisory_lock((j).job_id) AS locked
    FROM (
      SELECT (
        SELECT j
        FROM que_jobs AS j
        WHERE queue = $1::text
        AND run_at <= now()
        AND (priority, run_at, job_id) > (job.priority, job.run_at, job.job_id)
        ORDER BY priority, run_at, job_id
        LIMIT 1
      ) AS j
      FROM job
      WHERE NOT job.locked
      LIMIT 1
    ) AS t1
  )
)
SELECT queue, priority, run_at, job_id, job_class, args, error_count
FROM job
WHERE locked
LIMIT 1
```

This might look a little scary, but after understanding how to read a [recursive Postgres CTE](http://www.postgresql.org/docs/devel/static/queries-with.html), it an be deconstructed into a few more easily digestible components. Recursive CTEs generally take the form of `<non-recursive term> UNION [ALL] <recursive term>` where the initial non-recursive is evaluated and acts as an anchor to seed the recursive term. As noted in the Postgres documentation, the query is evaluated as follows:

1. Evaluate the non-recursive term. Place results into a temporary _working table_.
2. So long as the working table is not empty, repeat these steps:
    1. Evaluate the recursive term, substituting the contents of the working table for the recursive reference. Place the results into a temporary _intermediate table_.
    2. Replace the contents of the working table with the contents of the intermediate table and clear the intermediate table.

In the locking expression above, we can see that our non-recursive term finds the first job in the table with the highest work priority (as defined by `run_at < now()` and `priority`) and checks to see whether it can be locked with `pg_try_advisory_lock` (Que is implemented using Postgres advisory locks because they're atomic and fast). If it was locked successfully, the condition and limit outside of the CTE (`WHERE locked LIMIT 1`) stop it immediately and return that result. If the lock was unsuccessful, it recurses.

Each run of the recursive term does mostly the same thing as the non-recursive one, except that an additional predicate is added that only examines jobs of lower priority than the ones that have already been examined (`AND (priority, run_at, job_id) > (job.priority, job.run_at, job.job_id)`). By recursing continually given this stable sorting mechanism, jobs in the table are iterated one-by-one and a lock is attempted on each.

Eventually one of two conditions will be met that ends the recursion:

* A job is locked, iteration is stopped by `LIMIT` combined with the check on `locked`, and the expression returns.
* If there are no more candidates to lock, the select from `que_jobs` will come up empty, which will automatically terminate the expression.

Taking a closer look at the [jobs table DDL](https://github.com/chanks/que/blob/f95aec38a48a86d1b4c82297bc5ed9c88bb600d6/lib/que/migrations/1/up.sql#L11) we see that its primary key on (priority, run_at, job_id) should ensure that the expression above will run efficiently. We may be able to improve the locking algorithm's efficiency by introducing some random jitter so that workers run into less contention, but contention can't explain the multiple order of magnitude degradation in performance that we're seeing, so let's move on.

## Dead Tuples

By continuing to examine test data, we quickly notice another strong correlation. As the age of the oldest transaction increases, the number of dead tuples grows continually. The figure below shows how by the end of our experiment, we're approaching an incredible 100,000 dead rows.

<figure>
  <p><img src="/assets/postgres-queues/pre-dead-tuples.png"></p>
  <figcaption>Dead tuples.</figcaption>
</figure>

Automated Postgres VACUUM processes are supposed to clean these up, but upon closer inspection, we see that they can't be removed:

``` sql
=> vacuum verbose que_jobs;
INFO:  vacuuming "public.que_jobs"
INFO:  index "que_jobs_pkey" now contains 247793 row versions in 4724 pages
DETAIL:  0 index row versions were removed.
3492 index pages have been deleted, 1355 are currently reusable.
CPU 0.00s/0.02u sec elapsed 0.05 sec.
INFO:  "que_jobs": found 0 removable, 247459 nonremovable row versions in 2387 out of 4303 pages
DETAIL:  247311 dead row versions cannot be removed yet.
...
```

Notice the last line "247311 dead row versions cannot be removed yet". What this opaque Posgres error message is trying to tell is that these rows can't be removed because they're still potentially visible to another process in the system. It may seem counterintuitive that dead rows could have such serious performance implications for a live system, but they can. To understand why, we'll have to dig a little further into the Postgres MVCC model.

### The Postgres MVCC Model

```
# select xmin, xmax, job_id from que_jobs limit 5;
 xmin  | xmax | job_id
-------+------+--------
 89912 |    0 |  25865
 89913 |    0 |  25866
 89914 |    0 |  25867
 89915 |    0 |  25868
 89916 |    0 |  25869
(5 rows)
```

```
# start transaction isolation level serializable;
START TRANSACTION
```

```
# delete from que_jobs where job_id = 25865;
DELETE 1
```

```
# select xmin, xmax, job_id from que_jobs limit 5;
 xmin  | xmax  | job_id
-------+-------+--------
 89912 | 90505 |  25865
 89913 |     0 |  25866
 89914 |     0 |  25867
 89915 |     0 |  25868
 89916 |     0 |  25869
(5 rows)
```

<Postgres code>

Everytime a job is worked successfully, it gets harder to lock another job!

### Descending the B-tree

## Followers You Say?

## Towards a Solution

### Predicate Specificity

<figure>
  <p><img src="/assets/postgres-queues/post-queue-count.png"></p>
  <figcaption>Queue count.</figcaption>
</figure>

### Lock Multiple Jobs

### Batch Jobs to Redis

## Lessons Learned

A jobs table is the pathologic case, but this could manifest in any hot table.

Be careful with followers.

## Summary

Times:

* Without patch: 1430875700
* With patch: 1431038950
