---
title: allShortestPaths
layout: rneo4j
---

# Retrieve Shortest Paths

## Description

Retrieve all the shortest paths between two nodes.

## Usage

```r
allShortestPaths(fromNode, 
                 relType, 
                 toNode, 
                 direction = "out", 
                 max_depth = 1)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `fromNode`   | A node object. |
| `relType`   | The relationship type to traverse. Accepts a string. |
| `toNode`     | A node object. |
| `direction` | The relationship direction to traverse. Accepts "in" or "out". | 
| `max_depth` | The maximum depth of the path. Accepts an integer. |

## Value

A list of path objects. Returns NULL if no paths are found.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")
david = createNode(graph, "Person", name = "David")
elaine = createNode(graph, "Person", name = "Elaine")

createRel(alice, "WORKS_WITH", bob)
createRel(bob, "WORKS_WITH", charles)
createRel(bob, "WORKS_WITH", david)
createRel(charles, "WORKS_WITH", david)
createRel(alice, "WORKS_WITH", elaine)
createRel(elaine, "WORKS_WITH", david)

# The default max_depth of 1 will not find any paths.
# There are no length-1 paths between alice and david.
p = allShortestPaths(alice, "WORKS_WITH", david)
is.null(p)

# Set the max_depth to 4.
p = allShortestPaths(alice, "WORKS_WITH", david, max_depth = 4)
n = lapply(p, nodes)
lapply(n, function(x) sapply(x, function(y) y$name))

# Setting the direction to "in" and traversing from alice to david will not find a path.
p = allShortestPaths(alice, "WORKS_WITH", david, direction = "in", max_depth = 4)
is.null(p)

# Setting the direction to "in" and traversing from david to alice will find paths.
p = allShortestPaths(david, "WORKS_WITH", alice, direction = "in", max_depth = 4)
n = lapply(p, nodes)
lapply(n, function(x) sapply(x, function(y) y$name))
```

## See Also

[shortestPath](shortest-path.html)
