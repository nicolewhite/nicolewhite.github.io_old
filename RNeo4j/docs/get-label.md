---
title: getLabel
layout: rneo4j
---

# Node Labels

## Description

Get all node labels for a given node object or for the entire graph database.

## Usage

```r
getLabel(object)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `object`  | An object for which to view all node labels. Accepts a node or graph object (see details). |

## Value

A character vector.

## Details

Supplying a graph object returns all node labels in the graph database. Supplying a node object returns all node labels for the given node.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, name = "Alice")
bob = createNode(graph, name = "Bob")

addLabel(alice, "Student")
addLabel(bob, "Person", "Student")

# View all labels on the alice node.
getLabel(alice)

# View all node labels in the graph database.
getLabel(graph)
```

## See Also

[addLabel](add-label.html), [dropLabel](drop-label.html)
