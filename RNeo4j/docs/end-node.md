---
title: endNode
layout: rneo4j
---

`endNode`

# Retrieve Nodes from Relationships

## Description

Retrieve the ending node from a relationship object. This is the node for which the relationship is incoming.

## Usage

```r
endNode(rel)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `rel`     | A relationship object. |

## Output

A node object.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")

rel = createRel(alice, "WORKS_WITH", bob)

endNode(rel)

# Labels: Person
#
# $name
# [1] "Bob"
```

## See Also

[startNode](start-node.html)