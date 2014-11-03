---
title: incomingRels
layout: rneo4j
---

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

## Value

A list of relationship objects.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

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

# Get all incoming relationships on the david node.
david_incoming = incomingRels(david)

sapply(david_incoming, getType)

# Get the start nodes of all incoming relationships.
starts = lapply(david_incoming, startNode)

sapply(starts, function(s) s$name)

# Get all incoming "WORKS_WITH" relationships on the charles node.
charles_incoming_works = incomingRels(charles, "WORKS_WITH")

# Get the start nodes of all incoming "WORKS_WITH" relationships.
starts = lapply(charles_incoming_works, startNode)

sapply(starts, function(s) s$name)
```

## See Also

[outgoingRels](outgoing-rels.html)

