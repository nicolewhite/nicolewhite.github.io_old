---
title: dropIndex
layout: rneo4j
---

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
| `label`   | A node label for which to drop the index. Accepts a string. |
| `key`     | A property key for which to drop the index. Accepts a string. |
| `all`     | Set to TRUE to drop all indexes from the graph. |

## Details

Dropping a uniqueness constraint necessarily drops the index as well. It is unnecessary to use `dropIndex` if [dropConstraint](drop-constraint.html) has already been applied to the same (label, key) pair.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

createNode(graph, "Person", name = "Nicole", status = "Employed")
createNode(graph, "Person", name = "Drew", status = "Employed")
createNode(graph, "Person", name = "Aaron", status = "Unemployed")

createNode(graph, "School", name = "University of Texas at Austin", type = "Public")
createNode(graph, "School", name = "Louisiana State University", type = "Public")

addIndex(graph, "Person", "status")
addIndex(graph, "School", "type")

getIndex(graph)

# Drop the index on Person nodes by the name property.
dropIndex(graph, "Person", "status")

getIndex(graph)

# Drop all indexes from the graph database.
dropIndex(graph, all = TRUE)

getIndex(graph)
```

## See Also

[addIndex](add-index.html), [getIndex](get-index.html)





