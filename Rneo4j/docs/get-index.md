---
title: getIndex
layout: rneo4j
---

`getIndex`

# Indexes

## Description

View all indexes for a given label or for the entire graph database.

## Usage

```r
getIndex(graph, label = character())
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | The label for which to view all indexes. |

## Output

A data frame. Returns NULL if no indexes are found.

## Details

Supplying only a graph object as an argument returns all indexes in the graph database.

## Examples

View all indexes on the `Person` node label.

```r
getIndex(graph, "Person")
```

View all indexes in the graph database.

```r
getIndex(graph)
```

## See Also

[`addIndex`](add-index.html), [`dropIndex`](drop-index.html)