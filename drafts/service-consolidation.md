Steps:

0. Prepare data model.
1. Start double writing one direction.
2. Backfill.
3. Conditional traffic routing infrastructure.
4. Re-implement read API.
5. Re-implement write API w/ double writing.
6. Throttle up load.
7. Perform traffic analysis.
8. Cutover and SCRAM.
9. Fix bugs

## Cookie Preference Tracker

Let's introduce two simple services that we'd like to see consolidated. First off, we have our users service which handles user tracking and which will remain in operation after consolidation. It has a simple internal schema to track its data:

``` sql
CREATE TABLE users (
    id    SERIAL,
    email TEXT NOT NULL
);
```

It also has a single API endpoint that can be used to update attributes on a user:

```
PATCH /users/:email
```

Next we have our cookie preference tracking service which simply tracks whether a user has opted out of storing cookies on web properties. It references data in the users service with an e-mail address and has its own simple data model with its own primary key:

``` sql
CREATE TABLE user_cookie_preferences (
    id            SERIAL,
    email         TEXT NOT NULL,
    allow_cookies BOOLEAN NOT NULL
);
```

It also has a simple API endpoint that allows a user to flip their cookie preference one way or the other:

```
POST /update-allow-cookies
```

In our simple example above, we've realized that it was an overabstraction to move cookie preferences into a simple service. The microservice is too micro and suffers from lack of ownership, so we're going to merge it back into the main users service which is known to be well-monitored and well-maintained.

## Step 0: Prepare Data Model

First of all, we need to prepare our target database to receive the new information that we want it to store.

In our simple example, this involves adding a new column to track the `allow_cookies` option. Note that we've left it as nullable; this will allow us to start partially filling data, but give us an easy way to see what hasn't yet been filled:

``` sql
ALTER TABLE users
  ADD COLUMN allow_cookies BOOLEAN;
```

## Step 1: Double-write to Target

## Step 4: Read API

55 endpoints.
