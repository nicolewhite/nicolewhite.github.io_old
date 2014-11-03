---
title: getPaths
layout: rneo4j
---

# Retrieve Paths with Cypher Queries

## Description

Retrieve paths from the graph with a Cypher query.

## Usage

```r
getPaths(graph, query, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form key = value, if applicable. |

## Value

A list of path objects. Returns NULL if no paths are found.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice", age = 23)
bob = createNode(graph, "Person", name = "Bob", age = 22)
charles = createNode(graph, "Person", name = "Charles", age = 25)

createRel(alice, "KNOWS", bob)
createRel(alice, "KNOWS", charles)

query = "MATCH p = (:Person {name:'Alice'})-[:KNOWS]->(:Person) RETURN p"

paths = getPaths(graph, query)

lapply(paths, startNode)
lapply(paths, endNode)
```

## See Also

[getSinglePath](get-single-path.html)