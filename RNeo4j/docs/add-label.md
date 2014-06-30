---
title: addLabel
layout: rneo4j
---

# Node Labels

## Description

Add a label or multiple labels to an existing node object.

## Usage

```r
addLabel(node, ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `node`    | A node object to which to add the label(s). |
| `...`     | The label(s) to add to the node. Accepts a string or strings separated by commas. |

## Examples

```r
alice = createNode(graph, name = "Alice")
bob = createNode(graph, name = "Bob")
```

Add a single label.

```r
addLabel(alice, "Student")
```

Add multiple labels.

```r
addLabel(bob, "Person", "Student")
```

## See Also

[getLabel](get-label.html), [dropLabel](drop-label.html)