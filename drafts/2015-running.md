I set a goal for 2014 to run 1600 km, but fell short of it as I ended up only running 1379.2 km.

``` sql
WITH runs AS (
    SELECT date_part('month', occurred_at) month_num,
        count(*) AS num_runs,
        sum((metadata -> 'distance')::real) AS total_meters
    FROM events
    WHERE type = 'strava'
        AND metadata -> 'type' = 'Run'
        AND date_part('year', occurred_at) = 2014
    GROUP BY month_num
    ORDER BY month_num
), trips AS (
    SELECT content AS trip_name,
        (metadata -> 'start_date')::timestamp AS start,
        (metadata -> 'end_date')::timestamp AS end
    FROM events
    WHERE type = 'tripit'
        AND date_part('year', occurred_at) = 2014
), trips_enriched AS (
    SELECT t.trip_name,
        date_part('month', t.start) AS start_month,
        date_part('month', t.end) AS end_month
        date_part('month', t'end) + '1 month'::duration - '1 day'::duration AS 
    FROM trips t
), trips_start AS (
    SELECT t.start_month month_num,
        array_agg(trip_name) AS trips_start
    FROM trips_enriched t
    GROUP BY month_num
    ORDER BY month_num
), trips_end AS (
    SELECT t.end_month month_num,
        array_agg(trip_name) AS trips_end
    FROM trips_enriched t
    GROUP BY month_num
    ORDER BY month_num
)

SELECT to_char(to_timestamp(r.month_num::text, 'MM'), 'Month') AS month,
    num_runs,
    (total_meters / 1000)::int AS total_km,
    (total_meters / num_runs / 1000)::int AS average_km,
    array_to_string(array_cat(trips_start, trips_end), ', ') AS trips
FROM runs r
    LEFT JOIN trips_start ts ON r.month_num = ts.month_num
    LEFT JOIN trips_end te ON r.month_num = te.month_num;
```

```
   month   | num_runs | total_km | average_km |                  trips
-----------+----------+----------+------------+------------------------------------------
 January   |       17 |      140 |          8 |
 February  |       14 |      121 |          9 |
 March     |        8 |       57 |          7 | SXSW 2014
 April     |       14 |      107 |          8 |
 May       |       13 |      119 |          9 | API Days Berlin/Mediterranea 2014
 June      |       12 |       99 |          8 |
 July      |       15 |      117 |          8 | AWS Summit NYC 2014, Calgary Summer 2014
 August    |       12 |       78 |          7 | PAX 2014
 September |       14 |      110 |          8 |
 October   |       14 |      122 |          9 | Peter & Natalie's wedding
 November  |       18 |      138 |          8 |
 December  |       17 |      169 |         10 |
(12 rows)
```
