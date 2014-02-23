Data warehouse. The term immediately brings heavy enterprise into mind, complete with business intelligence, heavy XML-based ETL instructions, and "N-dimensional" data processing technology like the [OLAP hypercube](http://en.wikipedia.org/wiki/OLAP_cube).

A few months back, a colleague of mine [built an app](https://github.com/mfine/prism) that pulls commit data from within the Heroku organization down from the GitHub API. Over the course of a few days (pesky rate limiting), it backfilled the entire commit history of every project that the company ever created into a Postgres database, then left a scheduled process running to periodically update itself with new data.

The project had a specific goal. While web APIs are powerful tools, their RESTful paradigm often doesn't organize data in quite the way that you'd like to access it, preferring instead to present data as resources with highly consistent interfaces.

    GET /repos/:owner/:repo/commits/:sha

GitHub's API couldn't be used directly for any kind of advanced querying or analysis, but it could be leveraged to build a local reflection of that data, and that was exactly what the app was designed to do:

```
=> select org, repo, sha, date
   from commits
   where email = 'brandur@mutelight.org' or email = 'brandur@heroku.com'
   order by date desc
   limit 10;
  org   | repo |                   sha                    |          date
--------+------+------------------------------------------+------------------------
 heroku | api  | fad1459005ad049fdbb2c854731f14fafb3a77d4 | 2014-02-12 16:28:08+00
 heroku | api  | 7c479b3b8d7bd983f8eba2a8e8e0e3cc2678e23a | 2014-02-12 16:27:56+00
 heroku | api  | 73c7cbef78f68699b3c8847a016b075725d34d3b | 2014-02-12 16:27:29+00
 heroku | api  | 409bcd4251acfab459856951e3e4e4b76c5c91bb | 2014-02-12 16:25:39+00
 heroku | api  | c319c0f405afc6d06b8c40af54875511fa5a0961 | 2014-02-12 05:04:54+00
 heroku | api  | 33b82dae3cce7e1304f391e5420c8560b0acf600 | 2014-02-12 05:02:28+00
 heroku | api  | 81c2a6f5c3c5338cf4f27e14fcb738288953ed1f | 2014-02-12 04:51:48+00
 heroku | api  | 569619257571af50e7bc291afd1bc73818bfa030 | 2014-02-12 04:44:28+00
 heroku | api  | fb1e1e47048353c1bbddff1164ca87bde8d876d9 | 2014-02-12 00:49:39+00
 heroku | api  | 4cae708c0d3de1842c9bd9fd3e0ea8481f2fd946 | 2014-02-12 00:46:45+00
(10 rows)
```

With the data now fully housed in an RDMS, the powerful querying features of SQL are available to filter, map, transform, join, compare, and aggregate this data in any way imaginable. Better yet, although the volume of commit data on GitHub's servers is undoubtedly very large and would take non-trival time and system resources to process, we've succeeded in boiling it down to just the subset that we're interested in --- to the extent that nearly any kind of number crunching takes negligible time even on a tiny database.

``` sql
-- most commits in the last six months
select email, count(*) from commits
where date > now() - '6 months'::interval
group by email order by count desc limit 10;

-- most frequent weekend committers
select email, count(*) from commits
where extract(dow FROM date) in (0,6)
  and date > now() - '6 months'::interval
group by email order by count desc limit 5;

-- longest commit messages
select email, avg(char_length(msg)) from commits
where date > now() - '6 months'::interval
group by email order by avg desc limit 5;

-- and much more!
```

This is an example of a data warehouse (DWH) on a scale small enough to be agile, and by extension free of the negative connotations of heavy software and big enterprise, but still very useful for analysis and reporting. In the modern world, Postgres databases are cheap and primitive software building blocks needed to extract data from foreign sources (i.e. API SDKs, HTTP clients, RSS readers, etc.), are readily available in the form of gems or NPM packages, allowing simple DWHs like this one to be built from scratch with amazing rapidity. No XML or 200k LOC frameworks required --- only your language and libraries of choice and your favorite database.

As another example, I've been using a similar technique for years to [archive my tweets](https://github.com/brandur/blackswan). Compare this query to slowly manually paging back through your list of tweets looking for that link you posted six months ago:

```
=> select occurred_at, substr(content, 1, 50)
   from events where type = 'twitter'
     and content ilike '%iceland%'
     and metadata -> 'reply' = 'false'
   order by occurred_at desc
   limit 10;
     occurred_at     |                       substr
---------------------+----------------------------------------------------
 2013-07-22 04:24:57 | Half of Iceland now wants the old centre-right par
 2012-11-04 23:18:24 | The British, with a help of a Canadian (!) task fo
 2012-10-05 12:22:18 | What’s happening in Iceland’s metal scene? http://
 2011-12-28 20:55:46 | Have Icelandic lineage/ancestors? Then check out:
 2011-10-02 00:34:33 | Bar tending at the annual Icelandic fall feast. Dr
 2011-07-11 14:48:56 | Awesome. My brother just pointed out that there's
 2011-01-03 02:41:43 | Beautiful "Icelandic Dragon Sword" calligraphy cou
 2011-01-02 18:34:41 | "Icelandic Dragon Sword", since my actual name can
 2010-06-11 02:45:49 | #CCP is inspired by #Iceland: http://vimeo.com/122
 2010-06-07 22:49:13 | When your country's primary industry sinks, do thi
(10 rows)
```

Just like it's more expensive enterprise cousins, this warehouse has [its own ETL process](https://github.com/brandur/blackswan/blob/master/lib/black_swan/spiders/twitter.rb) for pulling down these tweets from Twitter's API and storing them. It's written in Ruby and leverages community gems to stay concise and DRY. Here's an excerpt:

``` ruby
res = Excon.get(
  "https://api.twitter.com/1.1/statuses/user_timeline.json",
  expects: 200,
  headers: {
    "Authorization" => "Bearer #{ENV["TWITTER_ACCESS_TOKEN"]}"
  },
  query: {
    count:            200,
    include_entities: "true",
    max_id:           options[:max_id],
    screen_name:      ENV["TWITTER_HANDLE"],
    since_id:         options[:since_id],
    trim_user:        "true",
  }.reject { |k, v| v == nil })
events = MultiJson.decode(res.body)
events.each do |event|
  next if \
    DB[:events].first(slug: event["id"].to_s, type: "twitter") != nil

  DB[:events].insert(
    content:     expand_urls(event),
    occurred_at: event["created_at"],
    slug:        event["id"].to_s,
    type:        "twitter",
    metadata: {
      reply:     (event["text"] =~ /^\s*@/) != nil,
    }.hstore)
end
```

This is the humble data warehouse --- a lightweight construct for developers. Its uses are unbounded, 
