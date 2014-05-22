---
title: cypher
layout: rneo4j
---

`cypher`

# Cypher Queries

## Description

Execute Cypher queries and retrieve Cypher results as a data frame.

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

## Output

A data frame. Cypher queries returning no results will return NULL and a message that the query was executed.

## Examples
Query without parameters.

```r
df = cypher(graph, "MATCH n RETURN n.name, n.age")
```

Query with parameters.

```r
df = cypher(graph, 
			"MATCH n WHERE n.age < {age} RETURN n.name, n.age", 
			age = 24)
```

Query that doesn't return anything.

```r
current_year = as.numeric(format(Sys.Date(), "%Y"))

cypher(graph, 
	   "MATCH n SET n.born = {year} - n.age REMOVE n.age",
	   year = current_year)
```