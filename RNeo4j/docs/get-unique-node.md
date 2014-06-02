---
title: getUniqueNode
layout: rneo4j
---

`getUniqueNode`

# Retrieve Nodes from the Graph Database by Label and Property

## Description

Retrieve a single node from the graph by specifying its label and unique key = value pair.

## Usage

```r
getUniqueNode(graph, label, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | A node label. Accepts a string. |
| `...`     | A key = value pair by which the node label is uniquely constrained. Only accepts one key = value pair. |

## Output

A node object. Returns NULL if a node is not found.

## Details

A uniqueness constraint must exist on the (label, key) pair in order to use this function. Specify a uniqueness constraint first with [`addConstraint`](add-constraint.html).

## Examples

```r
createNode(graph, "Person", name = "Alice")
createNode(graph, "Person", name = "Bob")

addConstraint(graph, "Person", "name")

alice = getUniqueNode(graph, "Person", name = "Alice")

alice

# Labels: Person
#
# $name
# [1] "Alice"
```

## See Also

[`getLabeledNodes`](get-labeled-nodes.html)