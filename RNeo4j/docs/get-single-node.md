---
title: getSingleNode
layout: rneo4j
---

# Retrieve Nodes from the Graph Database with Cypher Queries

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
createNode(graph, "Person", name = "Alice", age = 23)
createNode(graph, "Person", name = "Bob", age = 22)
createNode(graph, "Person", name = "Charles", age = 25)
```

Query without parameters.

```r
query = "MATCH (p:Person)
		 WITH p
		 ORDER BY p.age DESC
		 RETURN p 
		 LIMIT 1"
		 
oldest = getSingleNode(graph, query)

oldest

# Labels: Person
#
# $name
#[1] "Charles"
#
# $age
# [1] 25
```

Query with parameters.

```r
query = "MATCH (p:Person {name:{name}}) 
         RETURN p"

alice = getSingleNode(graph, query, name = "Alice")

alice

# Labels: Person
#
# $name
# [1] "Alice"
#
# $age
# [1] 23
```

## See Also

[getNodes](get-nodes.html)
