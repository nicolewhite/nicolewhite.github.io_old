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

If returning data, you can only query for tabular results. That is, this method has no current functionality for Cypher results containing array properties, collections, nodes, or relationships.

You can send Cypher queries without any return values (i.e., a Cypher query without the word `RETURN` in it).

## Value

A data frame. Cypher queries returning no results will return NULL.

## Examples

```r
createNode(graph, name = "Alice", age = 23)
createNode(graph, name = "Bob", age = 22)
createNode(graph, name = "Charles", age = 25)
```

Query without parameters.

```r
cypher(graph, "MATCH n RETURN n.name, n.age")

#    n.name n.age
# 1   Alice    23
# 2     Bob    22
# 3 Charles    25
```

Query with parameters.

```r
cypher(graph, 
	   "MATCH n WHERE n.age < {age} RETURN n.name, n.age", 
	   age = 24)

#   n.name n.age
# 1  Alice    23
# 2    Bob    22
```

Query with array parameter.

```r
names = c("Alice", "Charles")
cypher(graph,
	   "MATCH n WHERE n.name IN {names} RETURN n.name, n.age",
	   names = names)

#    n.name n.age
# 1 Charles    25
# 2   Alice    23
```

Query that doesn't return anything.

```r
cypher(graph, 
	   "MATCH n SET n.born = {year} - n.age REMOVE n.age",
	   year = 2014)

# Cypher executed, but did not return any results.

cypher(graph, 'MATCH n RETURN n.name, n.born')

#    n.name n.born
# 1   Alice   1991
# 2     Bob   1992
# 3 Charles   1989
```