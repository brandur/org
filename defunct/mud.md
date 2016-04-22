Years ago at Heroku we started running our own BUTC (Break Up the Core) initiative. Like many contemporaries, up to that point we'd built out the majority of the system's architecture in a Rails app that started out lean and graceful, but over time grew out to be large and gangling.

One by one, pieces of the core system (which was inventively given the moniker _Core_) were sliced off and went to inhabit their own corner of the system. The modules responsible for handling AWS infrastructure were broken out and called _Ion_. The modules responsible for provisioning Heroku Postgres databases were split off and named _Shogun_. The code used to track every running dyno was isolated and dubbed _Psmgr_. The billing system and invoice generator was extracted and called _the Vault_. Each of these systems was rearchitected and extended, and came to have their own teams that handled operating them and progressing their development. A colleague of mine once noted pithily, "Heroku's entire existence has been an exercise in breaking up Core."

For the most part this pattern worked out very well. We were careful to choose service boundaries between components that encapsulated domain logic in a way that was conceptually sound, and to only break off a service if the contract between its progenitor could be constrained well-enough to keep the interface surface area small. The teams that owned the new components generally no longer had to understand the entire context of the system's full architecture, which allowed them to focus their attention inward and improve the smaller piece of the product that fell into their territory. Technical quality improved as well; a more constrained area of responsibility naturally resulted in smaller codebases, and combined with new owners with a more refined sense of stewardship, those codebases could be refactored and improved significantly.

But it wasn't all good. The pattern that we'd been using for years to build out new services had some long-term flaws that only started to become visible as they accumulated. They were never easy to intuit because even with the flaws, the changes we were making were still obvious improvements over the architecture of the day.

## The Orchestrator (#orchestrator)

As mentioned previously, the original strategy used to start breaking out services was one where pieces of the original core system were sliced off and built into their own system. Each new service would be given an API, and Core would orchestrate the service based on what was happening inside the platform.

Even later as new services were born without having ever been part of the original system, the same basic stategy was used. An API was designed for the service and secondary mechanisms were built into Core that would make use of that API in order to integrate that new service into general workflows.

As time went on, a typical path in Core might look like the following where every new method called sent a message out to an external service to have it initiate work within its own domain:

``` ruby
def deploy(deploy_info)
  auditing_service.store_auditing_event()

  if deploy_info.new_deploy?
    database_service.provision_database()
    payment_service.update_payment_event()
  end

  dyno_service.update_dynos()
  webhook_service.run_webhooks()
end
```

Visually, it might look a little like Core acting as a general _orchestrator_ by facilitating the communication between itself and every other service:

``` monodraw
                             ┌──────────────────────┐                             
                             │                      │█                            
                             │                      │█                            
                             │                      │█                            
                             │         CORE         │█                            
                             │                      │█                            
                             │                      │█                            
                             │                      │█                            
                             └──────────────────────┘█                            
                              ███████████│████████████                            
                                         │                                        
            ┌────────────────────────────┼────────────────────────────┐           
            │                            │                            │           
            ▼                            ▼                            ▼           
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│                      │     │                      │     │                      │
│   Auditing Service   │     │   Billing Service    │     │     Dyno Service     │
│                      │     │                      │     │                      │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
```

This pattern of orchestration results in a few inherent problems. The general theme of these is that although many of the services external to the orchestrator can afford to simply serve up an API and be blissfully unaware as to how it gets called, the orchestrator starts to become increasing complex in that it needs to know about every other service in operation and how to use each one of them. The architecture still provides the advantage that the orchestrator can forego implementation details because it's communicating through an API, but it still needs to contain a significant amount of contextual detail that lets it know how to call into those APIs, and when.

### Problem: Split Responsibility (#split-responsibility)

When breaking a service off with a control surface API, something always gets left behind in the original service. This might look be as simple as a remote procedure call:

``` ruby
def deploy(deploy_info)
  dyno_service.update_dynos()
end
```

Although often quite clean in the beginning, this kind of orchestration logic has a tendency to become more complex over time, largely because the orchestrator provides such a convenient place to implement any type of high-level change. We can easily imagine making a few small (and very reasonable) tweaks to our simple call above:

``` ruby
def deploy(deploy_info)
  if app_tier_allows_update? && !abuse_service.abuse?
    dyno_service.update_dynos()
  end
end
```

Eventually it gets to the point where any change of substantial size to the domain being handled by a service requires a number of smaller changes across service boundaries:

1. Update to the service itself.
2. Update to the service's API.
3. Update to the orchestrator to call the new API appropriately.

This leads to more churn across components and deployments that need to be orchestrated with some care to make sure that the orchestrator is calling a compatible API at all times. It also makes prototyping changes more difficult in that many systems need to be touched in order to test a new feature.

#### Split State

But it gets even worse. Some services may require that they're called down to with some state so that they can properly perform their duties, and this could necessitate that the orchestrator starts storing service-specific state in its own database.

We hit this pitfall in a bad way when designing our billing system: any opened billing event could only be closed by using the identifier that was generated from the service when it was opened. Because the orchestrator was one of the very few components that generated billing events, the result was frequently that every billing event in the billing service had a direct equivalent in the orchestrator at all times. One day someone realized that due to the possibility of bugs that would occasionally cause drift in the billing service and orchestrator's data sets, it would be more efficient to generate invoices by first connecting to the orchestrator's database directly and reconciling against its data set (because it was orchestrating events, its data set was more likely to be problem free). This technique worked, but after accounting for the considerable communication overhead of a decoupled and distributed billing service, it made the value of the whole billing architecture far more questionable.

### Problem: Choke Point (#choke-point)

A single team contributing changes back to the orchestrator to enable new features in their own service is usually not a problem, but when the orchestrator is talking to twenty different distributed services, each of which needs changes in the orchestrator to implement any significant feature, contribution to the orchestrator becomes a project choke point.

This is obviously problematic to the service teams who need to wait longer to get their changes in, but it's also problematic for the orchestrator, which will trend towards a nosedive in quality without very vigilant maintainership. I use "nosedive" here because even if individual teams are doing a great job maintaining their own components, the orchestrator commonly becomes viewed as a foreign-owned piece of territory where it's undesirable but required to make changes, and in that kind of situation a [tragedy of the commons](http://en.wikipedia.org/wiki/Tragedy_of_the_commons) effect is inevitably the default.

### Problem: Operational Overhead (#operational-overhead)

As we all know, communication over a network is prone to failure. A working distributed architecture must have built-in mechanisms that allow it to compensate for calls that may have failed due a temporary blip in network connectivity, or for any other reason. In practice this often looks like an extra flag or row in a database that is set to successful or removed after state is confirmed to have been properly converged against a foreign service.

In the orchestrator architecture described above, all the overhead associate with operational problems in a set of distributed systems is offloaded onto the orchestrator. This is convenient for many services that are able to provide an API and not worry about how state gets converged, but results in a lot of extra responsibility being placed on the orchestrator. If there's a convergence problem in _any_ service anywhere in the system, it must be the investigated within the orchestrator. This is both burdensome and yet another choke point.

One manifestation of this that we'll see pretty frequently is when the owners of a service get a support ticket escalated to them that involves some kind of connectivity issues. Invariably, instead of being able to investigate it inside of their own stack, they'll have to go try to get visibility into the orchestrator or put in a cross-team request to close it out.

### Problem: Single Point of Failure (#spof)

Another side effect of the single orchestrator pattern is that the orchestrator becomes a single point of failure for the system: if it's down for any reason, it's difficult for any other service to stay up in a way where it's providing anything but extremely degraded functionality. This condition is aggravated even further because the orchestrator's wide surface area and very high rate of change makes problems more likely to occur.

### Advantage: Easy Point of Reference

Although I've covered its various problems in depth, it's worth considering that the single orchestrator is certainly not all bad. Having the orchestration logic all in one place makes it quite easy to figure out how some obscure part of the system works simply by referencing the relevant module in the orchestrator. If a high degree of code quality and convention can be maintained in the orchestrator, this kind of reference can be used by anyone in the company after they invest enough time to gain even a baseline familiarity with it.

This can also help with iteration speed in the same way that developing inside of a monolith is faster. If a change only requires some tweaks to the overall orchestration logic, it's possible that no other services need even be touched.

## The Big Ball of Mud

The single orchestrator is reminiscent of ["The Big Ball of Mud"](http://en.wikipedia.org/wiki/Big_ball_of_mud) as conceived by Brian Foote and Joseph Yoder. Even though is may not be quite as dire as a large software project with no architecture that's been thoroughly considered to any depth, it's still a situation where there's no obvious way to extend the system without continually making the orchestrator forever larger and more complex.

> A Big Ball of Mud is a haphazardly structured, sprawling, sloppy, duct-tape-and-baling-wire, spaghetti-code jungle. These systems show unmistakable signs of unregulated growth, and repeated, expedient repair.
>
> &mdash; Brian Foote and Joseph Yoder, _Big Ball of Mud_

As its size increases and its number of contributors grows, the orchestrator will inevitably trend toward an ever-decreasing standard of quality. The Big Ball of Mud is perpetually just over the horizon, laying in wait for that moment when quality in maintenance falters, or as a thousand tiny steps in the wrong direction finally brings it to the edge.

## The Log


### Transactional Consumers

### Inspiration: The Postgres WAL

[Postgres continuous archiving](http://www.postgresql.org/docs/9.4/static/continuous-archiving.html) is a major inspiration for this style of log-based architecture. Postgres can recover from a failure using a file-system level backup combined with a _write ahead log_ (WAL) to replay activity in the system up to the most recent possible state. This is almost directly symmetrical to the snapshots and events style of distributed architecture that we've already covered.

The primitives provided by Postgres are used by Heroku Postgres to implement rich platform features like [rollback](https://devcenter.heroku.com/articles/heroku-postgres-rollback), which finds an archived file-system level backup from before the target rollback time, and replays WAL against it until that target is reached.

## API Cohesion

References:

* [The Log](http://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying)
* [Event Sourcing](http://martinfowler.com/eaaDev/EventSourcing.html)
