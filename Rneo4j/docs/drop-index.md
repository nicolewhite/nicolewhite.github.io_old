---
title: dropIndex
layout: rneo4j
---

`dropIndex`

# Indexes

## Description

Drop index(es) for a given label and property key or for the entire graph database.

## Usage

```r
dropIndex(graph, label = character(), key = character(), all = FALSE)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | The node label for which to drop the index. |
| `key`     | The property key for which to drop the index. |
| `all`     | Set to TRUE to drop all indexes from the graph. |

## Details

Dropping a uniqueness constraint necessarily drops the index as well. It is unnecessary to use `dropIndex` if [`dropConstraint`](drop-constraint.html) has already been applied to the same (label, key) pair.

## Examples

Drop the index on `Person` nodes by the `name` property.

```r
dropIndex(graph, "Person", "name")
```

Drop all indexes from the graph database.

```r
dropIndex(graph, all = TRUE)
```

## See Also

[`addIndex`](add-index.html), [`getIndex`](get-index.html)





