I'll try to avoid the truly obvious advice.

At Heroku.

## Tips

### Design for Granularity

There's nothing worse than waking up in the middle of the night and discovering that an alert has gone of that doesn't have an obvious remediation because it could mean that any number of things have gone wrong. This inevitably leads to a drawn out investigation that's further slowed by the operator being half-asleep.

This one may seem obvious, but there are quite a few types of alerts that seem like a good idea until a closer inspection reveals that they're breaking the granularity rule. For example, an alert on something like a service's HTTP `/health` endpoint is a very widespread pattern, but for which a failure can mean anything from a thread deadlock to its database going down. A much more powerful alternative pattern is to have a background process constantly logging fine-grain health information on a wide range of system telemetry, and using that to implement alarms that try to detect each type of failure condition individually.

A goal to shoot for here is to make sure that every alarm in your system has a 1:1 ratio with a possible causation. If receiving an alert could mean that more than one thing has gone wrong, then there's probably room to make that alert more granular.

### Alert at the Root Cause

Alerts should be designed to measure against the metric being emitted by the system which is the most directly relevant to them. This is another one that seems like obvious advice, but even an alert designed by an advanced user can often be found to have a number of unnecessary abstractions layered on top of it when scrutinized closely. A system operator's goal here should be to slice through these abstractions until only the most basic level is left.

As an example, I previously wrote about how [long-lived transactions degraded the performance of our Postgres-based job queue](/postgres-queues). We'd originally been alerting based on the number of jobs in our background queue because that was the most obvious symptom of the problem. Upon closer study though, we realized that the job queue only bloated because the time to lock a job was increasing, so that lock time became a more obvious candidate for an alert. But going in even further, we realized that it was the number of dead tuples in an index's B-tree that was affecting the lock time, so that number seemed even more appropriate. But in a job queue with fairly constant throughput, the number of dead tuples in the index is a direct function of oldest transaction in the system, so in the end we settled on that as the most optimal fit for an alarm.

### Minimize External Services

In all cases except maybe your most mission critical system, it's not worth waking up your operators when a third party service goes down that one of your components happens to depend on. Keep your alerts inward-facing so that if they trigger, there's always meaningful action that can be taken by your team rather than just passing that page on to someone else.

By extension, wherever you have any measure of control (with other teams internally for example), try to encourage the operators of services that you depend on to maintain appropriate visibility into their own stacks. Your goal here is certainly to make sure that the system as a whole stays up, but that the team receiving the page are the ones with the best ability to influence the situation.

A misstep that we made internally is that the component that handled [Heroku Dropbox Sync](https://devcenter.heroku.com/articles/dropbox-sync) ended up being built on top of a rickety component that streamed platform events and which had a very poor track record for reliability. It was ostensibly owned by my own team, and we only had bare bones alerting on it. Dutifully though, they put an alarm in place around an end-to-end integration test that injected a release into a Heroku app and waited for it to come out of the other end. When the audit steamer failed, they got paged, and they re-raised those pages to us, resulting in a bad situation for everyone involved.

### Safe at Steady State

### Avoid Hypotheticals

### Throttle On Slowly

### Don't Allow Flappy Alarms to Enter the Shared Consciousness

### Treat Alarms as an Evolving System

### Empower Recipients to Improve the Situation

### Observe Ownership

## Summary
