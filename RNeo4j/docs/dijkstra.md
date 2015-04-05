---
title: dijkstra
layout: rneo4j
---

# Retrieve Weighted Shortest Paths

## Description

Retrieve the shortest path between two nodes weighted by a cost property.

## Usage

```r
dijkstra(fromNode,
         relType,
         toNode,
         cost_property,
         direction = "out")
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `fromNode`   | A node object. |
| `relType`   | The relationship type to traverse. Accepts a string. |
| `toNode`     | A node object. |
| `cost_property` | The name of the relationship property that contains the weights. Accepts a string. |
| `direction` | The relationship direction to traverse. Accepts "in" or "out". |

## Value

A path object. Returns NULL if a path is not found.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(neo4j, "Person", name = "Alice")
bob = createNode(neo4j, "Person", name = "Bob")
charles = createNode(neo4j, "Person", name = "Charles")
david = createNode(neo4j, "Person", name = "David")
elaine = createNode(neo4j, "Person", name = "Elaine")

r1 = createRel(alice, "KNOWS", bob, weight=1.5)
r2 = createRel(bob, "KNOWS", charles, weight=2)
r3 = createRel(bob, "KNOWS", david, weight=4)
r4 = createRel(charles, "KNOWS", david, weight=1)
r5 = createRel(alice, "KNOWS", elaine, weight=2)
r6 = createRel(elaine, "KNOWS", david, weight=2.5)

p = dijkstra(alice, "KNOWS", david, cost_property="weight")

p$length
p$weight
nodes(p)
```

## See Also

[allDijkstra](all-dijkstra.html)
