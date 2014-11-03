---
title: outgoingRels
layout: rneo4j
---

# Retrieve Relationships from Nodes

## Description 

Retreive a list of outgoing relationship objects from a node object, optionally filtering by relationship type.

## Usage

```r
outgoingRels(node, ...)
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

# Get all outgoing relationships on the bob node.
bob_outgoing = outgoingRels(bob)

# Get the end nodes of all outgoing relationships.
ends = lapply(bob_outgoing, endNode)

sapply(ends, function(e) e$name)

# Get all outgoing "KNOWS" relationships on the alice node.
alice_outgoing_knows = outgoingRels(alice, "KNOWS")

# Get the end nodes of all outgoing "KNOWS" relationships.
ends = lapply(alice_outgoing_knows, endNode)

sapply(ends, function(e) e$name)
```

## See Also

[incomingRels](incoming-rels.html)


