---
title: getID
layout: rneo4j
---

# Internal IDs of Nodes and Relationships

## Description

Retrieve the internal ID of a node or relationship object.

## Usage

```r
getID(object)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `object`  | The object for which to retrieve the internal ID. Accepts a node or relationship object. |

## Value

An integer.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")

getID(alice)

nodes = getNodes(graph, "MATCH n RETURN n")

sapply(nodes, getID)
```


