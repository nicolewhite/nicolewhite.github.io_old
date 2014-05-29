---
title: startNode
layout: rneo4j
---

`startNode`

# Retrieve Nodes from Relationships

## Description

Retrieve the starting node from a relationship object. This is the node for which the relationship is outgoing.

## Usage

```r
startNode(rel)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `rel`     | A relationship object. |

## Output

A node object.

## Examples

```r
rel = createRel(alice, "KNOWS", bob)
start = getStart(rel)

identical(start, alice)
# TRUE
```

## See Also

[`endNode`](end-node.html)