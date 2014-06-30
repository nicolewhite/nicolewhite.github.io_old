---
title: getSingleRel
layout: rneo4j
---

# Retrieve Relationships from the Graph Database with Cypher Queries

## Description

Retrieve a single relationship from the graph with a Cypher query.

## Usage

```r
getSingleRel(graph, query, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form key = value, if applicable. |

## Value

A relationship object. Returns NULL if a relationship is not found.

## Details

If your Cypher query returns more than one relationship, you will just arbitrarily get the first relationship returned. Be sure that you are specific enough to get the relationship you want.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")

createRel(alice, "WORKS_WITH", bob)
createRel(bob, "KNOWS", charles, since = 2000, through = "Work")
```

Query without parameters.

```r
query = "MATCH (:Person {name:'Alice'})-[r:WORKS_WITH]->(:Person {name:'Bob'})
         RETURN r"

rel = getSingleRel(graph, query)

startNode(rel)

# Labels: Person
#
# $name
# [1] "Alice"

endNode(rel)

# Labels: Person
# 
# $name
# [1] "Bob"
```

Query with parameters.

```r
query = "MATCH (:Person {name:{start}})-[r:KNOWS]->(:Person {name:{end}})
         RETURN r"

rel = getSingleRel(graph, query, start = "Bob", end = "Charles")

startNode(rel)

# Labels: Person
# 
# $name
# [1] "Bob"

endNode(rel)

# Labels: Person
#
# $name
# [1] "Charles"
```

## See Also

[getRels](get-rels.html)