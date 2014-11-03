---
title: nodes
layout: rneo4j
---

# Retrieve Nodes from Paths

## Description

Retrieve all nodes from a path object.

## Usage

```r
nodes(path)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `path`     | A path object. |

## Value

A list of node objects.

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

x = nodes(path)

sapply(x, function(n) n$name)
```

## See Also

[rels](rels.html)