---
title: getNodeByCypher
layout: rneo4j
---

`getNodeByCypher`

# Retrieve Nodes from the Graph Database

## Description

Retrieve a node object from the graph database with a Cypher query.

## Usage

```r
getNodeByCypher(graph, query, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form of key = value, if applicable. |

## Output

A node object.

## Details

If your Cypher query returns more than one node, you will just arbitrarily get the first node returned. Be sure to order your results by something meaningful and then use `LIMIT 1` to ensure you get the node you want.

## Examples

Query without parameters.

```r
query = "MATCH (p:Person)
		 WITH p
		 ORDER BY p.born 
		 RETURN p 
		 LIMIT 1"
		 
oldest = getNodeByCypher(graph, query)
```

Query with parameters.

```r
query = "MATCH (m:Movie {title:{title}}) RETURN m"

cloudatlas = getNodeByCypher(graph, query, title = "Cloud Atlas")
```