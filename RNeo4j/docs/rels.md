---
title: rels
layout: rneo4j
---

# Retrieve Relationships from Paths

## Description

Retrieve all relationships from a path object.

## Usage

```r
rels(path)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `path`     | A path object. |

## Value

A list of relationship objects.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")

createRel(alice, "WORKS_WITH", bob)
createRel(bob, "WORKS_WITH", charles)

path = getSinglePath(graph, "MATCH p = (:Person {name:'Alice'})-[:WORKS_WITH*]->(:Person {name:'Charles'}) RETURN p")

x = rels(path)

lapply(x, startNode)
lapply(x, endNode)
```

## See Also

[nodes](nodes.html)