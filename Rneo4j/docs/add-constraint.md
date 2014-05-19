---
title: addConstraint
layout: rneo4j
---

### `addConstraint`

#### Description
Add a uniqueness constraint to a label and property key.

#### Usage
```r
addConstraint(graph, label, key)
```

#### Arguments
| Parameter | Description     |
| --------- | --------------- |
| graph     | A graph object. |
| label     | The label on which to add the uniqueness constraint. Accepts a string.|
| key       | The property key that is constrained to be unique. Accepts a string.|

#### Details
A uniqueness constraint cannot be added to a (label, key) pair that already has an index applied. Attempting to add a uniqueness constraint where an index already exists results in an error. Use [`getIndex`](get-index.md) to view any pre-existing indexes. If you wish to add a uniqueness constraint, use [`dropIndex`](drop-index.md) to drop the index.

Adding a uniqueness constraint will necessarily create an index.

Attempting to add a uniqueness constraint to data that violates the uniqueness constraint results in an error.

#### Examples
```r
addConstraint(graph, "Person", "name")
```

#### See Also
[`getConstraint`](get-constraint.md), [`dropConstraint`](drop-constraint.md)
