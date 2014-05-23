---
title: createNode
layout: rneo4j
---

`createNode`

# Create Nodes

## Description

Create a node in the graph with the given label and properties.

## Usage

```r
createNode(graph, label = character(), ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `graph`   | A graph object. |
| `label`   | An optional node label. Accepts a string or vector of strings. |
| `...`     | Optional node properties in the form key = value (separated by commas). |

## Output

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

Create a node with a label and properties.

```r
bob = createNode(graph, "Person", name = "Bob", age = 24)
```

Create a node with multiple labels and properties.

```r
charles = createNode(graph, 
					 c("Person", "Student"), 
					 name = "Charles", 
					 age = 21)
```