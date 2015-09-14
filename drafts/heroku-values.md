In the spirit of [Adam Wiggins' inspiring list of Heroku values][wiggins-values] which was published around the the time of this departure from the company, I wanted to publish a list of my own as I make my own transition away.

My time at Heroku was easily the most valuable learning experience of my life, and I'll always remember my time there very fondly. So many parts of the job were such vast improvements over anywhere I'd worked before that I wanted to put at least a few of these great concepts down on paper for future reference (and hopefully re-use).

I should add the caveat that this is a compendium of values from the entire
duration of my stay at the company; not all had been established when I got
there, and not all were still in place when I left.

## Technology

### The Platform

I wouldn't go so far to say that companies should definitively use the Heroku
platform, but it is a good way to have one without a major investment in
infrastructure. As a company scales, it might be worth putting a self-hosted
one in place like Remind has done with [Empire][empire] or Soundcloud has done
with [Bazooka][bazooka] (PDF warning). GitHub's model of deploying experiments
and small apps to Heroku and eventually promoting them to more dedicated
infrastructure (if necessary) is also worthy of note.

### Dogfooding

Heroku OAuth.

Dashboard uses the V3 API. I can't even describe the number of bugs uncovered
by this technique; bugs that would have otherwise been encountered by
customers.

### Twelve Factor

I've previously read criticism on [twelve-factor][twelve-factor] which postulates that it's an artificial set of principles to work around limitations in the platform. I don't buy this for a second, but I'll let [Randall Degges cover this position][degges-12factor] because he puts it far more succinctly than I ever could.

Provided great internal conventions. We'd use it for apps on and off the platform.

### The HTTP API Design Guide

Interagent.

### Service Conventions

Pliny.

Productionization.

### Postgres

If given the opportunity to start from a blank slate, I can't say for sure that I would use some of our staple technologies like Ruby again, but Postgres is a certainty.

It's possible that we missed out on some cutting edge technologies that would
have offered major benefits, but the resources saved by _not_ jumping on every
database du jour is incalculable. There's probably still room in Heroku's stack
for an HA store, but it was the right thing to do to delay the introduction of
one until a number of mature options were available. In the meantime, we got
really good at operating Postgres.

The only thing better than Postgres itself was our Heroku Data team (known
affectionately internally as the DOD, or Department of Data). This team of
hugely talented engineers saved my skin an untold number of times as I dealt
[with pretty involved operational problems][postgres-queues] (thank-you
[Maciek][maciek] in particular for stepping in way more often than you should
have). I was told a number of times that I was their highest-maintenance
customer, and it was probably true. 
## Culture

### Leadership & Inspiration

I've never had the opportunity to work with so many people who inspired me on such a fundamental level as those who I met at Heroku, especially in my early days there. The company had everything: great leaders, inspiring thinkers, great engineers, and great designers.

### Self-service

Give people the tools to control their own destinies.

This value is hard to foster. People don't want self-service; they'd much prefer that you do their work for them. Keeping a culture of self-service alive requires a huge amount of discipline and perseverance, especially with a large influx of new employees who are more used to traditional corporate attitudes.

Prevents [constant disruption on open communication channels][slack-distractor].

### Cross-team Contribution

Pulls.

This one died, but while alive it was a beautiful thing.

### Shipping Cadence

No QA.

This was also something that had to be discovered at the organization level.
There was a period in Heroku's history where projects were hard to ship mostly
due to a weak process for getting them across the finish line. This problem was
examined and corrected, and today products make it out the door on a regular
basis.

### High Expectations for Engineers

No extreme specialization. Engineering talent is generally good enough that most people can solve most problems for themselves. Remember, engineers who need constant hand holding from other engineers are a not an asset, they're a cost center.

### Technical Culture

Workshop.

For quite some time we had an event every Friday called Workshop where
engineers could show off some of the interesting projects they were working. It
was designed to educate and inspire, and it worked.

### Flexible Environment

<figure>
  <p><img src="https://farm4.staticflickr.com/3685/9549450965_84f27e06b4_z.jpg"></p>
  <figcaption>The Agora Collective in Berlin.</figcaption>
</figure>

<!--
![Agora](https://farm6.staticflickr.com/5538/9549457229_fbd6c7c464_z.jpg)
-->

I worked from Berlin for roughly three weeks almost every year that I was at
the company.

I think the fact that I could do this was a testament to the company's ability
to hire well. If you've got the right people on your team, you can sit back and
relax knowing through blind faith alone that they're doing the right thing (even
if they're working from across the Atlantic).

### Coffee

For the longest time, there wasn't a coffee machine at Heroku, and I'm glad there wasn't, because if there had been I probably never would have learnt to make coffee with the Chemex pot.

Instead we had Chemex pots, a grinder, and paper filters. This sounds like some kind of hipster coffee elitism, and to some degree it is, but the idea was that making coffee would be five to ten minute process. This would in turn bring people together in the kitchen where they would have the opportunity to get away from their computers for a while and speak to their colleagues in-person. It works.

## Process & Organization

### GitHub

<figure>
  <p><img src="https://farm8.staticflickr.com/7727/16585790614_1b6a09c72e_z.jpg"></p>
  <figcaption>The OctoTrophy (dodgeball).</figcaption>
</figure>

GitHub. GitHub. GitHub. GitHub.

My belief that GitHub is the right way to organize is projects is actually part of a larger idea though, which is that developers should have the resources that they need to be successful and build their own highly optimized workflows. GitHub is one of those invaluable resources, along with its extremely healthy API and ecosystem of tools like [hub][hub] and [ghi][ghi], and complementing services like Travis.

The day that tools which didn't share these principles started to see popular use was sad indeed (I'm looking at you, Trello).

It was a sad day when I realized that Trello was becoming the most prevalent tool for organization at the company. Trello is the anti-GitHub: a horrific UI, the ugliest API available today without dipping into SOAP, dull tools, and completely non-functional basic features like plain text e-mail notifications.

Wikis.

### Resources

Provision the resources you need, including third party services from the large add-on catalog.

I've previously worked at companies where provisioning a job queue is a multi-month process involving endless meetings, territorial operations people, mountains of paperwork, and by the end of the whole ordeal, you have exactly one installation and have no answer to working with staging or development environments.

### Total Ownership

Our own version of "devops", total ownership was meant to convey that a team
responsible for the development of a component was also responsible for its
maintenance and production deployment. This added mechanical sympathy has huge
benefits in that getting features and bug fixes out is faster, manipulating
production is less esoteric, tasks that require otherwise tricky coordination
(like data migrations) are easier, and generally resulting in every person
involved taking more personal responsibility for the product (which leads to
more uptime).

Total ownership was instrumental in helping me to improve my game, but I'm
still a little on the fence about it. While I don't miss the multi-week
deployment schedules, I do miss the regular blocks of daily focus during which
I would never have to stop work and deal with an interruption from production.

### Organize Around Services

Following from total ownership, teams were built around the services that they owned.

Extract services and form teams around them.

### Technical Management

When I started at Heroku, my manager knew the codebase better than I did, knew
Ruby better than I did, and pushed more commits in a day than I would do in a
week. During our planning sessions we'd sketch in broad strokes on how certain
features or projects should be implemented, and leave it up to the
self-initiative of each engineer on the team to fill in the blanks. There
wasn't the time or the interest for micromanagement.

Communicating information to other teams and interested parties wasn't a game
of telephone because our manager was involved enough to be constantly aware of
what was happening.

We eventually moved to a place where a virtuous manager was one who had never
committed a line of code, responded to a page, or looked at a support ticket;
and who was expected to only have a tenuous grasp of the products that their
teams were building (i.e. probably the situation that most big organizations
have). But although technical management wasn't an idea that lasted, we saw the
promised land while it did.

[bazooka]: http://gotocon.com/dl/goto-zurich-2013/slides/AlexanderSimmerl_and_MattProud_BuildingAnInHouseHeroku.pdf
[degges-12factor]: http://www.rdegges.com/heroku-isnt-for-idiots/
[empire]: https://github.com/remind101/empire
[ghi]: https://github.com/stephencelis/ghi
[hub]: https://github.com/github/hub
[maciek]: https://twitter.com/uhoh_itsmaciek
[postgres-queues]: /postgres-queues
[slack-distractor]: http://www.guilded.co/blog/2015/08/29/slack-the-ultimate-distractor.html
[twelve-factor]: http://12factor.net/
[wiggins-values]: https://gist.github.com/adamwiggins/5687294
