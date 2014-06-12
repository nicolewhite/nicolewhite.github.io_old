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
| `label`   | A node label for which to drop the index. Accepts a string. |
| `key`     | A property key for which to drop the index. Accepts a string. |
| `all`     | Set to TRUE to drop all indexes from the graph. |

## Details

Dropping a uniqueness constraint necessarily drops the index as well. It is unnecessary to use `dropIndex` if [dropConstraint](drop-constraint.html) has already been applied to the same (label, key) pair.

## Examples

```r
createNode(graph, "Person", name = "Nicole", status = "Employed")
createNode(graph, "Person", name = "Drew", status = "Employed")
createNode(graph, "Person", name = "Aaron", status = "Unemployed")

createNode(graph, "School", name = "University of Texas at Austin", type = "Public")
createNode(graph, "School", name = "Louisiana State University", type = "Public")

addIndex(graph, "Person", "status")
addIndex(graph, "School", "type")

getIndex(graph)
#   property_keys  label
# 1        status Person
# 2          type School
```

Drop the index on `Person` nodes by the `name` property.

```r
dropIndex(graph, "Person", "status")

getIndex(graph)
#   property_keys  label
# 1          type School
```

Drop all indexes from the graph database.

```r
dropIndex(graph, all = TRUE)

getIndex(graph)
# No indexes in the graph.
```

## See Also

[addIndex](add-index.html), [getIndex](get-index.html)





