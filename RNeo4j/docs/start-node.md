---
title: startNode
layout: rneo4j
---

# Retrieve Nodes from Relationships

## Description

Retrieve the starting node from a relationship object. This is the node for which the relationship is outgoing.

## Usage

```r
startNode(rel)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `rel`     | A relationship object. |

## Value

A node object.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")

rel = createRel(alice, "WORKS_WITH", bob)

startNode(rel)

# Labels: Person
#
# $name
# [1] "Alice"tart, alice)
# TRUE
```

## See Also

[endNode](end-node.html)