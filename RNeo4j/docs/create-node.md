---
title: createNode
layout: rneo4j
---

# Create Nodes

## Description

Create a node in the graph with the given label and properties.

## Usage

```r
createNode(graph, .label = character(), ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `graph`   | A graph object. |
| `.label`  | Optional node label(s). Accepts a string or vector of strings. |
| `...`     | Optional node properties in the form key = value (separated by commas). |

## Value

A node object.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

# Node without properties.
mystery = createNode(graph)

# Node with properties.
alice = createNode(graph, name = "Alice", age = 23)

# Node with label and properties. Arrays can be added as properties as well.
bob = createNode(graph, "Person", name = "Bob", age = 24, kids = c("Jenny", "Larry"))

# Node with multiple labels and properties.
charles = createNode(graph, 
					 c("Person", "Student"), 
					 name = "Charles", 
					 age = 21)
```