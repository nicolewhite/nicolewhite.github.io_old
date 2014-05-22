---
title: deleteProp
layout: rneo4j
---

`deleteProp`

# Delete Node and Relationship Properties

## Description

For a node or relationship object, delete the named properties or delete all properties.

## Usage

```r
deleteProp(object, ..., all = FALSE)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `object`  | The node or relationship object for which the named properties will be deleted. |
| `...`     | The properties to be deleted. Accepts a single string or strings separated by commas. |
| `all`     | Set to TRUE to delete all properties on the node or relationship object. |

## Output

A node or relationship object.

## Examples

Delete the `age` property from the `alice` node.

```r
alice = deleteProp(alice, "age")
```

Delete the `name` and `age` properties from the `bob` node.

```r
bob = deleteProp(bob, "name", "age")
```

Delete all properties from the `charles` node.

```r
charles = deleteProp(charles, all = TRUE)
```

## See Also

[`updateProp`](update-prop.html)


