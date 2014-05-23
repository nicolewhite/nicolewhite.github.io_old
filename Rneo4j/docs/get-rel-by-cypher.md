---
title: getRelByCypher
layout: rneo4j
---

`getRelByCypher`

# Retrieve Relationships from the Graph Database

## Description

Retrieve a relationship object from the graph with a Cypher query.

## Usage

```r
getRelByCypher(graph, query, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form of key = value, if applicable. |

## Output

A relationship object.

## Examples

Query without parameters.

```r
query = "MATCH (:Person {name:'Tom Hanks'})-[a:ACTED_IN]->(:Movie {title:'Cloud Atlas'}) 
         RETURN a"
		 
rel = getRelByCypher(graph, query)

tom = getStart(rel)
cloudatlas = getEnd(rel)
```

Query with parameters.

```r
query = "MATCH (:Person {name:{name}})-[a:ACTED_IN]->(:Movie {title:{title}})
		 RETURN a"

rel = getRelByCypher(graph, query, name = "Clint Eastwood", title = "Unforgiven")

clint = getStart(rel)
unforgiven = getEnd(rel)
```

## See Also

[`getStart`](get-start.html), [`getEnd`](get-end.html)