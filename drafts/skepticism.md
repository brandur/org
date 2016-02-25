I just watched a tech talk on the use of subject of Haskell in production. It
went through the effort of pointing out in excruciating detail how most of the
the language's traditional pain points (e.g. high barrier to entry, difficulty
in hiring developers, ...) are nothing but silly myths with little basis in
reality.

## We're fine. We're all fine here now. How are you?

This got me thinking that it might be worthwhile to briefly consider how
healthy skepticism, a useful tool in all parts of life, can and should also be
applied when thinking about new technologies and technical architecture. If we
were to believe everything we read on engineering blogs and saw in conference
talks, we'd come away with the impression that:

* Building and maintaining a home-built language and VM gets you a huge
  performance boost and is a magnificent idea (Hack and HHVM at Facebook).
* Microservice architectures subdivide concerns perfectly and have very
  manageable relative overhead (Twitter).
* With a conducive enough environment, distributed engineering teams vastly
  increase the candidate pool and have a minimal incremental cost compared to
  local teams (GitHub).
* The only side-effect of deploying to JRuby is more speed (Square).
* Erlang is the most optimal choice for a high-performance routing system and
  conveys universal benefits (Heroku).
* Document stores are like RDMSes except with better performance and faster
  iteration speed because you don't have to deal with all those annoying
  constraints. Everybody should be using Mongo (Parse and many others).
* You're throwing away uptime if you're not on a proprietary distributed
  database that has incredible availability characteristics (Riak).
* Moving to an immutable event log based on an in-house technology (Kafka) is
  close to a perfect architecture as you could hope (LinkedIn).
* Custom built workflow and distributed cron systems are an excellent
  complexity to productivity trade-off (Airflow and Chronos at AirBnB).

While all of these statements have some _basis in truth_, none of them are true
in the way that their originators would have you believe. I'm also purposely
being a little hard on all these companies to make the point; if you were to
ask candidly if there were downsides to any of these technologies, they
wouldn't lie to you, but the default is to leave that part of the story
unspoken. It's also worth nothing that I'm 100% guilty of making these sorts of
claims myself.

## The Dirt

A blog post or a tech talk is a little like a sales pitch. It's much more
subtle than what you'll get at your local used car lot, but the author is still
trying to sell something, whether that's a superior engineering culture to help
with recruiting, or just trying to improve their own renown as an expert in the
field. To that end, it's in their best interest to keep attention focused
squarely on the good. Very few people are going to get up on stage and talk
about how things at their company _don't work very well_.

This has the effect of creating a body of material that's highly biased towards
the most optimistic interpretation of any situation. Personally, I'd be much
more interested to hear about the dirt; what happens down in the grimy trenches
of production, and how everything has gone wrong at some point and how that's
normal part of engineering. But until more people are comfortable talking about
it, a healthy level of skepticism should be exercised at all times.
