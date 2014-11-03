---
title: getSingleNode
layout: rneo4j
---

# Retrieve Nodes with Cypher Queries

## Description

Retrieve a single node from the graph with a Cypher query.

## Usage

```r
getSingleNode(graph, query, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form key = value, if applicable. |

## Value

A node object. Returns NULL if a node is not found.

## Details

If your Cypher query returns more than one node, you will just arbitrarily get the first node returned. Be sure to order your results by something meaningful and then use `LIMIT 1` to ensure you get the node you want.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

createNode(graph, "Person", name = "Alice", age = 23)
createNode(graph, "Person", name = "Bob", age = 22)
createNode(graph, "Person", name = "Charles", age = 25)

# Query without parameters.
query = "MATCH (p:Person)
		 WITH p
		 ORDER BY p.age DESC
		 RETURN p 
		 LIMIT 1"
		 
oldest = getSingleNode(graph, query)

# Query with parameters.
query = "MATCH (p:Person {name:{name}}) 
         RETURN p"

alice = getSingleNode(graph, query, name = "Alice")
```

## See Also

[getNodes](get-nodes.html)
