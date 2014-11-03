---
title: updateProp
layout: rneo4j
---

# Update Node and Relationship Properties

## Description

For a node or relationship object, update its properties. Existing properties can be overridden and new properties can be added.

## Usage

```r
updateProp(object, ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `object`  | A node or relationship object. |
| `...`     | Property updates or additions in the form key = value (separated by commas). |

## Value

A node or relationship object.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

alice = createNode(graph, "Person", name = "Alice")

# Update the age property and add an eyes property to the alice node.
alice = updateProp(alice, age = 24, eyes = "green")
```

## See Also

[deleteProp](delete-prop.html)