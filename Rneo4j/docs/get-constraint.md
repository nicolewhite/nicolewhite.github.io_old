---
title: getConstraint
layout: rneo4j
---

`getConstraint`

# Uniqueness Constraints

## Description

View all uniqueness constraints for a given label or for the entire graph database.

## Usage

```r
getConstraint(graph, label = character())
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | The label for which to view all uniqueness constraints. |

## Output

A data frame. Returns NULL if no constraints are found.

## Details

Supplying only a graph object as an argument returns all uniqueness constraints in the graph database.

## Examples

View all uniqueness constraints on the `Person` node label.

```r
getConstraint(graph, "Person")
```

View all uniqueness constraints in the graph database.

```r
getConstraint(graph)
```

## See Also

[`addConstraint`](add-constraint.html), [`dropConstraint`](drop-constraint.html)