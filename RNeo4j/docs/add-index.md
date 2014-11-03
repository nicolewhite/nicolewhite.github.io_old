---
title: addIndex
layout: rneo4j
---

# Indexes

## Description

Add an index to a label and property key.

## Usage

```r
addIndex(graph, label, key)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `graph`   | A graph object. |
| `label`   | A node label on which to add the index. Accepts a string. |
| `key`     | A property key by which the label will be indexed. Accepts a string. |

## Details

An index already exists for any (label, key) pair that has a uniqueness constraint applied. Attempting to add an index where a uniqueness constraint already exists results in an error. Use [getConstraint](get-constraint.html) to view any pre-existing uniqueness constraints. If a uniqueness constraint already exists for the (label, key) pair, then it must be true that the index exists as well; adding an index is unnecessary.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

createNode(graph, "Person", name = "Nicole", status = "Employed")
createNode(graph, "Person", name = "Drew", status = "Employed")
createNode(graph, "Person", name = "Aaron", status = "Unemployed")

addIndex(graph, "Person", "status")
```

## See Also

[getIndex](get-index.html), [dropIndex](drop-index.html)