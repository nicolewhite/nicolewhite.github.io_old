---
title: getLabeledNodes
layout: rneo4j
---

# Retrieve Nodes by Label and Property

## Description

Retrieve nodes from the graph with the specified label and optional key = value pair.

## Usage

```r
getLabeledNodes(graph, label, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | A node label. Accepts a string. |
| `...`     | An optional key = value pair by which to filter the results. Only accepts one key = value pair. |

## Value

A list of node objects. Returns NULL if no nodes are found.

## Examples

```r
createNode(graph, "School", name = "University of Texas at Austin")
createNode(graph, "School", name = "Louisiana State University")

createNode(graph, "Person", name = "Nicole", status = "Employed")
createNode(graph, "Person", name = "Drew", status = "Employed")
createNode(graph, "Person", name = "Aaron", status = "Unemployed")

schools = getLabeledNodes(graph, "School")

sapply(schools, function(s) s$name)

# [1] "University of Texas at Austin" "Louisiana State University"

employed_people = getLabeledNodes(graph, "Person", status = "Employed")

sapply(employed_people, function(p) p$name)

# [1] "Nicole" "Drew"
```

## See Also

[getUniqueNode](get-unique-node.html)