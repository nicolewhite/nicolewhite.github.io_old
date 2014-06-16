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
| `label`   | A node label for which to drop the uniqueness constraint. Accepts a string. |
| `key`     | A property key for which to drop the uniqueness constraint. Accepts a string. |
| `all`     | Set to TRUE to drop all uniqueness constraints from the graph. |

## Details

Dropping a uniqueness constraint necessarily drops the index as well. It is unnecessary to use [dropIndex](drop-index.html) if `dropConstraint` has already been applied to the same `(label, key)` pair.

## Examples

```r
createNode(graph, "Person", name = "Alice")
createNode(graph, "Person", name = "Bob")

createNode(graph, "City", name = "San Francisco")
createNode(graph, "City", name = "Austin")

addConstraint(graph, "Person", "name")
addConstraint(graph, "City", "name")

getConstraint(graph)

#   property_keys  label       type
# 1          name   City UNIQUENESS
# 2          name Person UNIQUENESS
```

Drop the uniqueness constraint on `Person` nodes by the `name` property.

```r
dropConstraint(graph, "Person", "name")

getConstraint(graph)

#   property_keys label       type
# 1          name  City UNIQUENESS
```

Drop all uniqueness constraints from the graph database.

```r
dropConstraint(graph, all = TRUE)

getConstraint(graph)

# No constraints in the graph.
```

## See Also

[addConstraint](add-constraint.html), [getConstraint](get-constraint.html)
