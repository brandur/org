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
    SELECT date_part('month', occurred_at) month_num,
        array_to_string(array_agg(content), ', ') AS trips
    FROM events
    WHERE type = 'tripit'
        AND date_part('year', occurred_at) = 2014
    GROUP BY month_num
    ORDER BY month_num
)
SELECT to_char(to_timestamp(r.month_num::text, 'MM'), 'Month') AS month,
    num_runs,
    (total_meters / 1000)::int AS total_km,
    (total_meters / num_runs / 1000)::int AS average_km,
    trips
FROM runs r LEFT JOIN trips t ON r.month_num = t.month_num;
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
