The streamlined Kinesis API makes implementing a basic consumer a simple task, but the fact that parts of a Kinesis stream can split or merge at any time should be taken into consideration while assembling clients that will be used for non-trivial applications. The cases that a well-behaved consumer should consider are as follows:

1. A consumer is listening to the stream and a shard splits.
2. A consumer is listening to the stream and a shard merges.
3. A consumer is offline and a shard splits.
4. A consumer is offline and a shard merges.

The property that we'd like to see across all of the cases above is a guarantee that at no point in time do we consume events for any given partition key in any order _except_ the order in which they were produced. If a shard splits, we should consume its entirety of records before moving onto any new shards that were created during the split.

## Split

In order to build a correct but simple algorithm, it's important to understand that any given shard's hash key range is _immutable_. This means that when a hash key range is to be broken up like in the event of a split, the shard managing the original range is closed and two new shards are opened in its place.

The following diagram illustrates this concept. `shard0` originally manages hash space `A + B`, then splits. After the split, hash space `A` is handled by `shard1` and `B` by `shard2`. `shard0` becomes closed permanently and will henceforth only be used as an artifact that demarcates where a split occurred.

```
shard     |    records/time --->
----------+--------------------------------------------------------
shard0    |    A1    B1    A2    B2    A3    B3    <CLOSED>
shard1    |                                        A4    A5    A6
shard2    |                                        B4    B5    B6
```

## Merge

A merge looks very similar to a split. The parent and the _adjacent parent_ shards both become closed (`shard0` and `shard1`), and a new shard child shard is created to handle their combined hash key range (`A` + `B`).

```
shard     |    records/time --->
----------+--------------------------------------------------------
shard0    |    A1    A2    A3    <CLOSED>
shard1    |    B1    B2    B3    <CLOSED>
shard2    |                      A4    B4    A5    B5    A6    B6
```

## Generalized Algorithm

Based on the information above, a generalized algorithm that will guarantee our required property of record order based on partition key can be broadly described in two steps:

1. Consume all closed shards to completion (sequentially, and in order).
2. Consume open shards.

The immutability of a shard's hash space is the key property of a Kinesis stream that allows us to grossly simplify a rather complicated problem. Each closed shard acts as an important piece of a stream's historical record, and by checking that we correctly consumed each one to completion, we are assured that record sequence by hash space is strictly ascending.

The following pseudocode implements the generalized consumer algorithm in a more concrete way:

``` ruby
shards = describe_stream()

closed_shards, open_shards =
  shards.partition { |shard| shard.closed }

# Probably a no-op because shards are already ordered according to when they
# closed. The takeaway though is that we want to consume shards that closed
# earlier first to guarantee order.
closed_shards.sort_by! { |shard| shard.ending_sequence_number }

closed_shards.each do |closed_shard|
  # Check to see if we have anything left to consume in this shard. Usually we
  # will not because the chances are that each shard has been closed for a
  # while and we will have already consumed it until the end.
  last = last_consumed_sequence_number(closed_shard)
  if closed_shard.ending_sequence_number > last
    consume_until(closed_shard, closed_shard.ending_sequence_number)
    checkpoint(closed_shard, closed_shard.ending_sequence_number)
  end
end

open_shards.each do |open_shard|
  Thread.new do
    consume(open_shard)
  end
end
```

### Running Consumers

Due to the nature of a split or a merge, a consumer which is online is never in any danger of consuming misordered events because by necessity, any split or merge will result in new shards being created. These new shards will strictly contain only records that were produced _after_ all records in their parent streams.

Knowing this, we can re-use the same algorithm as above. When we detect a split or a merge, we stop all running consumers, and restart the consumer algorithm from scratch.

``` ruby
# we can detect a split or merge by checking periodically to see whether any
# new shards exist
loop do
  if new_shards()
    stop_all_consumers()
  end
  sleep(10)
end

# start generalized algorithm from above
shards = describe_stream()

...
```

### Ephemeral Consumers

An _ephemeral consumer_ is defined here as one that if taken offline, is happy to restart consumption of a stream from its latest point. This is different from a _stateful consumer_ which will attempt to consume any records that it missed during its absence. Although the "best effort" nature of an ephemeral consumer suggests that it might not make the correct handling of shard splits and merges strictly necessary, it should still try to correctly handle a split or merge that's detected while the consumer is online.

Ephemeral consumers should maintain in-memory checkpoints that represent the last sequence number that they consumed to for each shard that has been open at any point while it's been online. When a split or merge occurs, the consumer should restart (as explained in [above](#running-consumers)) and use those checkpoints to consume any shards that it had been consuming, but which are now closed, to the end. Shards which are closed, but which the ephemeral consumer has never seen, can safely be ignored.

The algorithm above can be alterered slightly to get this behavior:

``` ruby
...

closed_shards.each do |closed_shard|
  # as an ephemeral consumer, skip the closed shard if we've never seen it
  # before
  next unless known?(closed_shard)

  last = last_consumed_sequence_number(closed_shard)
  if closed_shard.ending_sequence_number > last
    consume_until(closed_shard, closed_shard.ending_sequence_number)
    checkpoint(closed_shard, closed_shard.ending_sequence_number)
  end
end

...
```
