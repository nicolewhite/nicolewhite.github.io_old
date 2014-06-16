---
title: incomingRels
layout: rneo4j
---

`incomingRels`

# Retrieve Relationships from Nodes

## Description

Retreive a list of incoming relationship objects from a node object, optionally filtering by relationship type.

## Usage

```r
incomingRels(node, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `node`    | A node object.  |
| `...`     | Optional relationship type(s) by which to filter the results. Accepts a string or strings separated by commas. |

## Output

A list of relationship objects.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")
david = createNode(graph, "Person", name = "David")

createRel(alice, "KNOWS", bob)
createRel(alice, "KNOWS", charles)
createRel(charles, "KNOWS", david)

createRel(alice, "WORKS_WITH", david)
createRel(bob, "WORKS_WITH", david)
createRel(bob, "WORKS_WITH", charles)
```

Get all incoming relationships on the `david` node.

```r
david_incoming = incomingRels(david)

sapply(david_incoming, getType)

# [1] "WORKS_WITH" "WORKS_WITH" "KNOWS"
```

Get the start nodes of all incoming relationships.

```r
starts = lapply(david_incoming, startNode)

sapply(starts, function(s) s$name)

# [1] "Alice" "Bob" "Charles"
```

Get all incoming `WORKS_WITH` relationships on the `charles` node.

```r
charles_incoming_works = incomingRels(charles, "WORKS_WITH")
```

Get the start nodes of all incoming `WORKS_WITH` relationships.

```r
starts = lapply(charles_incoming_works, startNode)

sapply(starts, function(s) s$name)

# [1] "Bob"
```

## See Also

[outgoingRels](outgoing-rels.html)

