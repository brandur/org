In the spirit of [Adam Wiggins' inspiring list of Heroku values][wiggins-values] which was published around the the time of this departure from the company, I wanted to publish a list of my own as I make my own transition away.

My time at Heroku was easily the most valuable learning experience of my life, and I'll always remember my time there very fondly. So many parts of the job were such vast improvements over anywhere I'd worked before that I wanted to put at least a few of these great concepts down on paper for future reference (and hopefully re-use).

Note that this is a compendium of values from the entire duration of my stay at
the company; not all had been established when I got there, and not all were
still in place when I left.

## Technology

### The Platform

I wouldn't go so far to say that companies should definitively use the Heroku
platform, but it is a good way to have one without a major investment in
infrastructure. As the company scales, it might be worth putting your own in
place like Remind has done with [Empire][empire] or Soundcloud has done with
[Bazooka][bazooka] (PDF warning). GitHub's model of deploying experiments and
small apps to Heroku and eventually promoting them to more dedicated
infrastructure if necessary is also worthy of note.

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

It's possible that we missed out on some cutting edge technologies that would have offered major benefits, but the resources saved by _not_ jumping on every database du jour is incalculable. There is probably room in Heroku's stack for an HA store, but the decision can be delayed until a few mature options are available; get good at operating Postgres in the meantime.

Having a crack team of hugely talented Postgres engineers available to help out in case I ran into a really tough problem didn't hurt my positive outlook on the database either. I can't even count the number of times that this team bailed my team out of situations that we'd never be able to resolve on our own.

## Culture

### Leadership & Inspiration

I've never had the opportunity to work with so many people who inspired me on such a fundamental level as those who I met at Heroku, especially in my early days there. The company had everything: great leaders, great engineers, and great designers.

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

### Coffee

For the longest time, there wasn't a coffee machine at Heroku, and I'm glad there wasn't, because if there had been I probably never would have learnt to make coffee with the Chemex pot.

Instead we had Chemex pots, a grinder, and paper filters. This sounds like some kind of hipster coffee elitism, and to some degree it is, but the idea was that making coffee would be five to ten minute process. This would in turn bring people together in the kitchen where they would have the opportunity to get away from their computers for a while and speak to their colleagues in-person. It works.

## Process & Organization

### GitHub

<figure>
  <p><img src="https://farm8.staticflickr.com/7727/16585790614_1b6a09c72e_z.jpg"></p>
  <figcaption>The OctoTrophy (for dodgeball).</figcaption>
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

This position is disputable, but it helped me a lot personally.

Reduces the friction to shipping. No committee required.

### Organize Around Services

Following from total ownership, teams were built around the services that they owned.

Extract services and form teams around them.

### Technical Management

When I started, my manager knew the codebase better than I did, and pushed more commits. Even _if_ they had wanted to micromanage me (and they didn't), they just didn't have the time to do so. And having a manager that did more than bikeshed on e-mail lists and move Trello cards around was a huge inspiration.

Communicating things to other teams and interested parties isn't a constant game of telephone because your manager is already involved and knows exactly what's going on.

This situation sadly didn't last, but while it did, it was the promised land.

[bazooka]: http://gotocon.com/dl/goto-zurich-2013/slides/AlexanderSimmerl_and_MattProud_BuildingAnInHouseHeroku.pdf
[degges-12factor]: http://www.rdegges.com/heroku-isnt-for-idiots/
[empire]: https://github.com/remind101/empire
[ghi]: https://github.com/stephencelis/ghi
[hub]: https://github.com/github/hub
[slack-distractor]: http://www.guilded.co/blog/2015/08/29/slack-the-ultimate-distractor.html
[twelve-factor]: http://12factor.net/
[wiggins-values]: https://gist.github.com/adamwiggins/5687294
