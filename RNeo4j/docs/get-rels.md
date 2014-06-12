---
title: getRels
layout: rneo4j
---

`getRels`

# Retrieve Relationships from the Graph Database with Cypher Queries

## Description

Retrieve relationships from the graph with a Cypher query.

## Usage

```r
getRels(graph, query, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `query`   | A Cypher query in the form of a string. |
| `...`     | Optional parameters to pass to the query in the form key = value, if applicable. |

## Output

A list of relationship objects. Returns NULL if no relationships are found.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")
david = createNode(graph, "Person", name = "David")

createRel(alice, "KNOWS", bob)
createRel(alice, "KNOWS", charles)
createRel(charles, "KNOWS", david)

createRel(bob, "WORKS_WITH", david)
createRel(alice, "WORKS_WITH", david)
```

Query without parameters.

```r
all_knows = getRels(graph, "MATCH (:Person)-[k:KNOWS]->(:Person) RETURN k")
```

Get the start nodes of all "KNOWS" relationships.

```r
starts = lapply(all_knows, startNode)

sapply(starts, function(s) s$name)

# [1] "Alice"   "Alice"   "Charles"
```

Query with parameters.

```r
alice_outgoing = getRels(graph, "MATCH (:Person {name:{name}})-[r]->(:Person) RETURN r", name = "Alice")

sapply(alice_outgoing, getType)

# [1] "WORKS_WITH" "KNOWS" "KNOWS"  
```

## See Also

[getSingleRel](get-single-rel.html)