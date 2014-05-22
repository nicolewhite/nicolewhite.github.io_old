---
title: getLabel
layout: rneo4j
---

`getLabel`

# Node Labels

## Description

View all node labels for a given node object or for the entire graph database.

## Usage

```r
getLabel(object)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `object`  | The object for which to view all node labels. Accepts a node object or a graph object (see details). |

## Output

A character vector.

## Details

Supplying a graph object returns all node labels in the graph database. Supplying a node object returns all node labels for the given node.

## Examples

View all node labels on the `alice` node.

```r
getLabel(alice)
```

View all node labels in the graph database.

```r
getLabel(graph)
```

## See Also

[`addLabel`](add-label.html), [`dropLabel`](drop-label.html)
