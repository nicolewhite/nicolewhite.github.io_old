---
title: getEnd
layout: rneo4j
---

`getEnd`

# Retrieve Nodes from Relationships

## Description

Retrieve the ending node from a relationship object. This is the node for which the relationship is incoming.

## Usage

```r
getEnd(rel)
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
end = getEnd(rel)

identical(end, bob)
# TRUE
```

## See Also

[`getStart`](get-start.html)