---
title: createRel
layout: rneo4j
---

`createRel`

# Create Relationships

## Description
Create a relationship between two nodes with the given type and properties.

## Usage

```r
createRel(fromNode, type, toNode, ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `fromNode` | A node object from which the relationship will be outgoing. |
| `type` | A relationship type in the form of a string (see details). |
| `toNode` | A node object to which the relationship will be incoming. |
| `...` | Optional relationship properties in the form key = value (separated by commas). |

## Output

A relationship object.

## Details

The string supplied for the `type` argument will be converted to uppercase and all spaces will be replaced with underscores. That is,

```r
createRel(alice, "works with", bob)
```

is equivalent to

```r
createRel(alice, "WORKS_WITH", bob)
```

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")
```

Relationship without properties.

```r
rel = createRel(alice, "works with", bob)
```

Relationship with properties.

```r
rel = createRel(alice, "works with", charles, since = 2000, through = "Work")
```

## See Also
[`startNode`](start-node.html), [`endNode`](end-node.html)