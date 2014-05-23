---
title: getNodeByIndex
layout: rneo4j
---

`getNodeByIndex`

# Retrieve Nodes from the Graph Database

## Description

Retrieve a node object from the graph by specifying its label and indexed (key = value) pair.

## Usage

```r
getNodeByIndex(graph, label, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | A node label. Accepts a string. |
| `...`     | A key = value pair by which the node label is indexed. Only accepts one key = value pair. |

## Output

A node object.

## Details

If you have not specified a uniqueness constraint for the label and property, you will arbitrarily get the first indexed node found with the given label and property value. It is suggested that you specify a uniqueness constraint first with [`addConstraint`](add-constraint.html).

## Examples

```r
addConstraint(graph, "Person", "name")

alice = getNodeByIndex(graph, "Person", name = "Alice")
```

