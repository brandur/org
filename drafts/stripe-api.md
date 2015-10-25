After doing a write-up on [designing the Heroku API](/heroku-api), I thought it
might be interesting to take a closer look at some of the design
characteristics of the Stripe API. I was not involved at all in its early
design, but its developer friendliness and features lead to it being often
cited as an example of good API design.

## Features (#features)

### Documentation (#documentation)

### Language Bindings (#bindings)

### Request and Response Introspection (#introspection)

My personal favorite Stripe API innovation, it allows you to get visibility
into your own requests. It's more common practice these days for services to
hand you a [request ID](/request-ids) on an error so that internal engineering
groups can see what happens, but Stripe allows you to log into its dashboard
and look at your own request/response information. This might help you
understand what parameters you ended up sending in or see exactly what went
wrong with your request.

### Request IDs (#request-ids)

There is great tooling for these internally as well. Given a request ID
submitted by a user, we're able to see a large amount of associated metadata as
well as precise details on the structure of both the request and response.

### Testmode (#testmode)

### Versioning and Erosion Resistance (#versioning)

Account-level version lock-in with header override.

The internal implementation for this is surprisingly clean too. "Gates" hide
features or define how particular requests are interpreted, and their
definition allows a working range of HTTP versions to be specified.

### IRC Support (#irc-support)

As noted right on [Stripe's support index](https://support.stripe.com/), help
is available in the form of an IRC channel on FreeNode. Although not a hard
technical bullet, having a way to get quick help when developing against the
product is a pretty nice feature. Stripe has an internal team called Dev
Support tasked specifically with helping out on the front lines and who will
rapidly hand bugs or other deficiencies off to internal engineering teams as
necessary.

## Failures (#failures)

### Form Encoding

`application/x-www-form-urlencoded`

* Can't represent non-string data types.
* Can't encode an empty list.
* Can't encode a null value. We use an empty string in some places as a
  stand-in, but as any developer can tell you, the semantics of a null and an
  empty string are quite different.
* The way that the encoding of arrays of hashes works is downright scary.
  Re-ordering parameters will break it completely.

### Modernized HTTP Semantics

`PATCH`

### Subresource Abuse

Nested arrays of subresources that are addressed by index. This unfortunately
leads to problems such as necessitating a global lock on the parent resource.
