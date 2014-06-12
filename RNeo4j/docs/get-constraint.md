---
title: getConstraint
layout: rneo4j
---

`getConstraint`

# Uniqueness Constraints

## Description

Get all uniqueness constraints for a given label or for the entire graph database.

## Usage

```r
getConstraint(graph, label = character())
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | A node label for which to view all uniqueness constraints. Accepts a string. |

## Output

A data frame. Returns NULL if no constraints are found.

## Details

Supplying only a graph object as an argument returns all uniqueness constraints in the graph database.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice")
bob = createNode(graph, "Person", name = "Bob")

san_fran = createNode(graph, "City", name = "San Francisco")
austin = createNode(graph, "City", name = "Austin")

addConstraint(graph, "Person", "name")
addConstraint(graph, "City", "name")
```

Get all uniqueness constraints on `Person` nodes.

```r
getConstraint(graph, "Person")

#   property_keys  label       type
# 1          name Person UNIQUENESS
```

Get all uniqueness constraints in the graph database.

```r
getConstraint(graph)

#   property_keys  label       type
# 1          name   City UNIQUENESS
# 2          name Person UNIQUENESS
```

## See Also

[addConstraint](add-constraint.html), [dropConstraint](drop-constraint.html)