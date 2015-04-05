---
title: allDijkstra
layout: rneo4j
---

# Retrieve Weighted Shortest Paths

## Description

Retrieve all the shortest paths between two nodes weighted by a cost property.

## Usage

```r
allDijkstra(fromNode,
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

A list of path objects. Returns NULL if no paths are found.

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

p = allDijkstra(alice, "KNOWS", david, cost_property="weight")

p[[1]]$length
p[[1]]$weight
nodes(p[[1]])

p[[2]]$length
p[[2]]$weight
nodes(p[[2]])
```

## See Also

[dijkstra](dijkstra.html)
