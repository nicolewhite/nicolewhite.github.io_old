---
title: cypher
layout: rneo4j
---

# Retrieve Cypher Query Results as a Data Frame

## Description

Retrieve Cypher results query results as a data frame.

## Usage

```r
cypher(graph, query, ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- 
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form key = value, if applicable. |

## Details

If returning data, you can only query for tabular results. That is, you can't return node or relationship entities. See [getNodes](get-nodes.html) and [getRels](get-rels.html) for returning entities.

You can send Cypher queries without any return values (i.e., a Cypher query without the word `RETURN` in it).

## Value

A data frame. Cypher queries returning no results will return NULL.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice", age = 23)
bob = createNode(graph, "Person", name = "Bob", age = 22)
charles = createNode(graph, "Person", name = "Charles", age = 25)
david = createNode(graph, "Person", name = "David", age = 20)

createRel(alice, "KNOWS", bob)
createRel(alice, "KNOWS", charles)
createRel(charles, "KNOWS", david)

# Query without parameters.
cypher(graph, "MATCH n RETURN n.name, n.age")

# Query with parameters.
cypher(graph, 
	   "MATCH n WHERE n.age < {age} RETURN n.name, n.age", 
	   age = 24)

# Query with array parameter.
names = c("Alice", "Charles")
cypher(graph,
	   "MATCH n WHERE n.name IN {names} RETURN n.name, n.age",
	   names = names)
     
# Query that returns a collection.
# The 'friends' column will have lists as values.
df = cypher(graph, "MATCH (n)-[:KNOWS]-(m) RETURN n.name, COLLECT(m.name) AS friends, COUNT(m) AS num_friends")
sapply(df, class)
df$friends

# Query that doesn't return anything.
cypher(graph, 
	     "MATCH n SET n.born = {year} - n.age REMOVE n.age",
	     year = 2014)

cypher(graph, 'MATCH n RETURN n.name, n.born')
```
