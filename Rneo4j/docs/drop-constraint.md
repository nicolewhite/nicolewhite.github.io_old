---
title: dropConstraint
layout: rneo4j
---

`dropConstraint`

# Uniqueness Constraints

## Description

Drop uniqueness constraint(s) for a given label and property key or for the entire graph database.

## Usage

```r
dropConstraint(graph, label = character(), key = character(), all = FALSE)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | The node label for which to drop the uniqueness constraint. |
| `key`     | The property key for which to drop the uniqueness constraint. |
| `all`     | Set to TRUE to drop all uniqueness constraints from the graph. |

## Details

Dropping a uniqueness constraint necessarily drops the index as well. It is unnecessary to use [`dropIndex`](drop-index.html) if `dropConstraint` has already been applied to the same `(label, key)` pair.

## Examples

Drop the uniqueness constraint on `Person` nodes by the `name` property.

```r
dropConstraint(graph, "Person", "name")
```

Drop all uniqueness constraints from the graph database.

```r
dropConstraint(graph, all = TRUE)
```

## See Also

[`addConstraint`](add-constraint.html), [`getConstraint`](get-constraint.html)
