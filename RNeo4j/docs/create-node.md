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

Create a node without properties.

```r
mystery = createNode(graph)
```

Create a node with properties.

```r
alice = createNode(graph, name = "Alice", age = 23)
```

Create a node with a label and properties. Arrays can be added as properties.

```r
bob = createNode(graph, "Person", name = "Bob", age = 24, kids = c("Jenny", "Larry"))
```

Create a node with multiple labels and properties.

```r
charles = createNode(graph, 
					 c("Person", "Student"), 
					 name = "Charles", 
					 age = 21)
```