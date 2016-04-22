On my semi-annual re-read of [Steve Yegge's famous rant on APIs and platforms](https://plus.google.com/+RipRowan/posts/eVeouesvaVX)

* Activity introspection (e.g. events that a user has performed or that have occurred on an app)
* Credential rotation for API keys or database users
* Internal password resets
* Mail re-sends where the originals have failed due to a bounce or similar reason
* Manual state re-synchronization between internal components
* Procurement of new internal OAuth clients
* Usage information and feature availability in internal APIs (e.g. a general user look-up for use by internal services)

Simultaneously operating a service while continuing to make forward progress on its development can be a daunting task, providing fewer excuses for incoming interrupts can help mitigate that.

## Tiers

1. **APIs:**
2. **Tooling:**

## Acccessibility

1. **Provide tooling:**
2. **Discoverable:**
3. **Announced and regularly referenced:**

## Tenets

1. **Complete:**
2. **Reliable:**

## Feature Iteration

Look for patterns.

## Examples

### Credential Rotation With `pg:credentials --reset`

### OAuth `trusted` Flag

## Anti-patterns

1. **Tooling without API:**
2. **Build and forget:**
3. **Saying "yes" anyway:**
