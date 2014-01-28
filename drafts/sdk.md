Recently the topic of whether it was better practice to use an SDK or basic HTTP calls when interacting with the API of a foreign service came up [on Programmable Web](http://blog.programmableweb.com/2013/10/04/when-sdks-are-better-than-apis/) and in [Traffic and Weather episode 20](http://trafficandweather.io/posts/2013/12/27/episode-20-im-going-to-punch-a-wall). The question mostly depends on the premise that many services provide modern RESTful APIs whose endpoints do a good job of encapsuling basic actions that users are interested in, and very little specialized logic is required to implemented on the client-side, keeping even direct HTTP calls relatively simple. The trade-off then ends up being taking on an extra depedency in return for an abstraction layer in the language of your choice.

Heroku's internal Ruby culture is extensive enough that over the years, as a group was shipping a new service, it was fairly common to also ship a client gem to help talk to it. Those gems would act as lightweight SDKs for the convenience of developers, and get bundled into any projects that needed to interact with the services that they were abstracting. This pattern was pretty effective, but in the end I largely started stripping them out of any apps that I was working on after observing enough side effects that emerged from their use.

Here's why I don't want your SDK in production.

## Instrumentation

We end up investigating enough tricky problems that it's pretty important for anything that happens inside our apps to produce fairly detailed log trails that will later empower us to analyze exactly what went on. These traces contain standard log information like the the request's resulting response code and elapsed time, but should ideally also include app-specific information like the current [request ID](/request-ids), and follow the same format conventions that are used elsewhere in the app.

We could wrap any SDKs to include the extra logging, but by making our own HTTP calls, we can [build a single Excon instrumentor](https://github.com/geemus/excon#instrumentation) and re-use it for every service that we call.

## Metrics

Following the same idea as logging, we also want to emit metrics around any calls to foreign services so that we can track the quality of their operation. What's the average service time? How often does it respond with a 503? Does it ever return internal server errors? If the service is critical enough to the operation of our own app, we might even want to put alarms in place around these metrics because if its operating in a degraded state, that might bubble up to us directly.

## Performance and Persistent Connections

The performance of calls to foreign services that are in hot paths is concerning enough that we might want to try to optimize them by keeping pools of persistent connections around.

Does an SDK handle this? Maybe. Does it handle it correctly for any given app's concurrency model? Again, maybe; every SDK has to be examined on a case-by-case basis. We can bypass the uncertainly completely by standardizing on a common pattern for connection re-use against all services that we interact with.

## Error Handling, Edge Cases, and Idempotency

There's huge variability in the way that SDKs handle errors and other types of less common edge cases. I've seen everything from allowing the exceptions produced by the SDK's internal HTTP library bubble back up to our code to swallowing problems completely and passing invalid data back to us. Even in the best case scenario where an SDK has identified and documented every failure scenario, we still have to consider every error and figure out what to with it. By making basic HTTP calls, we can re-use patterns across services. For example, in most cases when we get a 503 back, we'll bubble that 503 back up to the consumer of our app.

Retries are also worth considering here. If it look like we just hit a basic network problem, and we know of an endpoint to be idempotent, we might want to retry the call a few times. An SDK could do this too, but we can't know its exact behavior without digging into it, and even then it might not be doing the right thing.

## The Grep Test

Especially when connection problems and errors bubble up, it's often useful to be able to identify what segment of code was trying to make a call to some HTTP endpoint. When working with basic HTTP calls, working that out is [one grep away](http://jamie-wong.com/2013/07/12/grep-test/), but with SDKs this often has to be reasoned out by comparing the host in a URL to the name of a library.

## Just Freedom Patch!

It's true that the points above are still possible with SDKs be it through designing pluggable SDKs, monkey patching, or building sophisticated wrappers. The problem is that these SDKs are being shipped from by different companies and different people and will have wildly different conventions and capabilities throughout, all of which need to be investigated and learned on a case-by-case basis, and the options above probably won't represent a big time saving compared to just wrapping the HTTP calls yourself and re-using the patterns that you already have.

So instead of shipping SDKs with every bell and whistle, let's just endeavor to build nicer APIs.
