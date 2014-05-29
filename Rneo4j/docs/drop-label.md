---
title: dropLabel
layout: rneo4j
---

`dropLabel`

# Node Labels

## Description

Drop label(s) from a node.

## Usage

```r
dropLabel(node, ...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `node`    | A node object from which to drop the given label(s). |
| `...`   | The label(s) to drop from the node. Accepts a single string or strings separated by commas. |

## Examples

Drop the `Person` label from the `alice` node.

```r
dropLabel(alice, "Person")
```

Drop the `Person` and `Student` labels from the `bob` node.

```r
dropLabel(bob, "Person", "Student")
```

## See Also

[`addLabel`](add-label.html), [`getLabel`](get-label.html)
