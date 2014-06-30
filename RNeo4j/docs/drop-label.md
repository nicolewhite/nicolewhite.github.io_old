---
title: dropLabel
layout: rneo4j
---

# Node Labels

## Description

Drop label(s) from a node.

## Usage

```r
dropLabel(node, ..., all = FALSE)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `node`    | A node object from which to drop the given label(s). |
| `...`     | The label(s) to drop from the node. Accepts a single string or strings separated by commas. |
| `all`     | Set to TRUE to drop all labels from the node. |

## Examples

Drop the `Person` label from the `alice` node.

```r
dropLabel(alice, "Person")
```

Drop all labels from the `bob` node.

```r
dropLabel(bob, all = TRUE)
```

## See Also

[addLabel](add-label.html), [getLabel](get-label.html)
