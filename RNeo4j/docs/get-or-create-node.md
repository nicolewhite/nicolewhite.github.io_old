---
title: getOrCreateNode
layout: rneo4j
---

# Create Unique Node or Retrieve Unique Node

## Description

Create a unique node or retrieve it if it already exists.

## Usage

```r
getOrCreateNode(graph, .label, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `.label`   | A node label. Accepts a string. |
| `...`     | Node properties in the form key = value, separated by commas. The first key = value pair listed must be the uniquely constrained key = value pair for the given node label. |

## Value

A node object.

## Details

A uniqueness constraint must exist for the given node label and first key = value pair listed in `...`. Use [addConstraint](add-constraint.html) to add a uniqueness constraint.

## Examples

```r
createNode(graph, "Person", name = "Alice", age = 24)
createNode(graph, "Person", name = "Bob", age = 21)

addConstraint(graph, "Person", "name")
```

Alice is retrieved from the graph; a new node is not created.

```r
alice = getOrCreateNode(graph, "Person", name = "Alice")

alice

# Labels: Person
#
# $name
# [1] "Alice"
#
# $age
# [1] 24
```

Additional properties listed after the unique key = value pair are ignored if the node is retrieved instead of created.

```r
bob = getOrCreateNode(graph, "Person", name = "Bob", age = 22)

bob

# Labels: Person
#
# $name
# [1] "Bob"
#
# $age
# [1] 21
```

Node doesn't exist, so it is created.

```r
charles = getOrCreateNode(graph, "Person", name = "Charles")

charles

# Labels: Person
#
# $name
# [1] "Charles"
```

There are now three nodes in the graph.

```r
length(getLabeledNodes(graph, "Person"))

# [1] 3
```

