Although real-time APIs are generally considered to be of increasing importance due to the rise of mobile, especially when compared to other update mechanisms like polling, it seems that there is a fairly general and somewhat surprising lack of consensus around what an ideal system here should look like. Even amongst organizations that are considered forward thinking when it comes to topics like APIs there's still a number of different ideas and implementations to choose from. I use the word "ideal" to refer to a number of different desirable characteristics:

* **Useful:** the system should properly serve the needs of consumers that are trying to use it.
* **Accessible:** uses a fairly open standard so that it's usable from a variety of different types of consumers.
* **Reliable:** there's a clear strategy for consumers to get a good guarantee that they'll receive all the messages they're interested in, and for them to recover from error conditions.
* **Performant:** self-explanatory.

I recently attended a discussion session on real-time APIs at a recent API summit in Detroit, and the group's relative silence seemed to strongly suggest that no one had great first-hand information on their own successful implementations, or even had favored public implementations that they wanted to talk about.

## Application to the Platform

I'll mainly be considering applicability when it comes to the API component in this article, but the findings can be applied to other areas as well. As far as private platform components go, the following services which API talks to on a regular basis could be considered to be candidates for the consumption of a real-time API if such a product existed (content in brackets is the mechanism that API currently uses to communicate with these components):

* Data Warehouse (DB poll)
* Event Manager (async push)
* Ion (sync push)
* Logplex (sync push)
* Maestro (async push)
* Nile (async push)
* Psmgr (sync push)
* Vault (sync push)
* Vault Usage (DB poll and async push)
* Zendesk SSO (async push)

Components flagged as "async push" would be especially conducive to being moved to a unified real-time API. Given such an API that's performant and reliable enough, I also believe that the components marked with "sync push" could consider using it as well. Components that update by DB poll will be more difficult to move over, but it benefit API in the long term if they could also become consumers one day.

In addition, given the possibility of a fairly general solution, public consumers would likely find such an API quite useful as well to keep themselves up-to-date. The most obvious example would be addon service providers who could listen for addon provisioning and deprovisioning events.

## Considerations

There are a few key technical considerations to look at for possible implementations:

* **Message delivery guarantee:** I'll use this term to refer to the problem of "at least once" delivery. Although not critical for all use cases of a real-time API, it is absolutely critical for some, especially when considering internal components. For example, if a component like Maestro is listening to API's event stream, it must receive _every_ domain addition or removal event without fail.
* **Parallelism:** When the scale of data reaches a large enough threshold, it's a huge win to be able to easily parallelize consumers to ensure that scaling out even further isn't a problem.

## Implementations

A number of approaches have been explored in a wild. I've tried to include a few popular options, but of course there are many other possibilities that are not listed.

### HTTP Streaming

HTTP streaming works by having a client establishing a connection to a streaming endpoint, then taking advantage of chunked transfer encoding to continuously receive data. This option is quite visible due to it being the real-time implementation used by Twitter for its [public streams](https://dev.twitter.com/docs/streaming-apis/streams/public).

An obvious downside to HTTP streaming is that parallelization is difficult and its complexity is offloaded to the client. To start up a number of consuming processes, clients must design their own strategy for partitioning the data stream. Each consuming process will still receive the entire stream, but will have to understand which messages to process and which to ignore using some pre-defined logic like `<message ID> % <consumer ID>`. Furthermore, parallelization is expensive for the server as well, because the entire stream must be sent out to every consumer, even if those consumers are only consuming part of it. Twitter for example has deemed streaming so expensive, that each of their clients is only allowed to open a single stream. That said, a shared partitioning strategy between the server and clients is a definite possibility, but makes implementation more complex on both sides.

Message delivery guarantees are also offloaded to consumers. Consumers must keep track of which ID they last consumed so that if they lose connection, they know which offset to request data from when they re-connect. If a consumer is down for a long period of time, generating the initial dump of data to get them resynced can also be quite an expensive operation for the server, especially for APIs backed by a relational database like Psmgr's lockstep. Alternative stores like Kafka could help mitigate this, but after a certain size of data, such operations will always be expensive.

**WebSockets** are another implementation option here. The commentary above applies to them as well.

### XMPP

A solid option for a real-time API is always the [Extensible Messaging and Presence Protocol](http://help.hipchat.com/knowledgebase/articles/64377-xmpp-jabber-support-details) (XMPP), a reliable messaging protocol that's been used to support the real-time portion of APIs by companies like [HipChat](http://help.hipchat.com/knowledgebase/articles/64377-xmpp-jabber-support-details). Overall, the use of XMPP is actually not too dissimilar from something like HTTP streaming, although over a protocol that's a little better suited for messaging, and which is open and mature enough that many languages should now have fairly robust clients built for consuming it.

As with HTTP streaming, any kind of parallelization and message delivery guarantee are difficult without offloading a lot of that design to consumers, or coming up with a shared server/client strategy for how this is supposed to work.

One criticism of XMPP is that although servers which run the protocol like Ejabberd are quite mature pieces of software, they are still somewhat cumbersome to setup and maintain. Having recently built a HipChat XMPP consumer in Ruby myself, I'd say that although the XMPP library available there is pretty good, it doesn't have anywhere near the polish, good documentation, or support that you could expect from other areas in Ruby like HTTP.

### Webhooks

Another option that received quite a bit of attention for some time were webhooks, and this strategy is still used by providers such as [Stripe](https://stripe.com/docs/webhooks), [GitHub](https://help.github.com/articles/post-receive-hooks), and to some degree, even Heroku (deployhooks), although the latter two to a lesser extent. The general idea is that consumers subscribe by pointing the provider to their receive URL, and the provider responds by publishing events to that URL.

A major advantage to webhooks is that parallelization is easily solved: by using the same strategies as any server uses to handle parallel requests, any consumer can easily parallelize to any extent. If servers are consuming from something like Kafka which supports partitions, it's also quite easy for them to parallelize as well. By setting up a topic with multiple partitions, any number of servers can make calls out to any number of clients.

The problem of message delivery guarantee is moved to the server instead of the client, which is a great feature for consumers, but which would make servers much more onerous to operate as they will have to continuously retry messages until they can be delivered. API already has a lot of experience with this problem through its interactions with components like Maestro and Vault Usage, although those components being able to operate like "dumb servers" removes the lion's share of their operational burden, rather than that burden disappearing, it is instead only shifted onto the API component.

Misbehaving clients also become an issue here &mdash; clients which successfully receive events, but which do so in a very slow manner could backlog a server unless it takes particular precautions against this type of client. Strategies like keeping connections open to receiving clients for as long as possible, or very short timeouts could help mitigate this problem.

There is also a possibility that webhooks could be a supoptimal implementation for  **mobile clients**, as the necessity to have a receiving URL might make consumption more difficult. On the other hand though, most of mobile seems to be moving toward push notifications, and it should be trivial to build a simple server to intercept webhook pushes and convert them to something like Apple push notifications for mobile clients.

### Kafka

Kafka could potentially be considered as an implementation as well, but its lack of an authentication system means that it will be very difficult for consumers in the public or which run on the platform (no authentication system means that permission control is accomplished via ingress/egress rules in AWS) to ever consume it. Furthermore, although advanced features like partitioning are extremely useful, they may undesirably raise the bar for getting started when consuming the real-time API. It's a strong possibility that whatever system we choose will be powered by Kafka, but it may not be the ideal interaction layer of the API.

## Conclusion (tl;dr)

HTTP streaming and XMPP are strong and open possibilities, but force complex logic into every consumer that uses them. Webhooks solves this problem, but comes with increased operational burdern, however, consolidation of the interfaces used by today's internal consumers could help lower that burden.
