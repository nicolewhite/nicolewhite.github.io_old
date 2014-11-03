---
title: endNode
layout: rneo4j
---

# Retrieve Nodes from Relationships

## Description

Retrieve the ending node from a relationship or path object.

## Usage

```r
endNode(object)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `object`     | A relationship or path object. |

## Value

A node object.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")

rel = createRel(alice, "WORKS_WITH", bob)

endNode(rel)

query = "
MATCH p = (a:Person)-[:WORKS_WITH]->(b:Person)
WHERE a.name = 'Alice' AND b.name = 'Bob'
RETURN p
"

path = getSinglePath(graph, query)

endNode(path)
```

## See Also

[startNode](start-node.html)