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
| `object`  | A node or relationship object for which the named properties will be deleted. |
| `...`     | The properties to be deleted. Accepts a single string or strings separated by commas. |
| `all`     | Set to TRUE to delete all properties on the node or relationship object. |

## Output

A node or relationship object.

## Examples

```r
alice = createNode(graph, "Person", name = "Alice", age = 23, status = "Married")
bob = createNode(graph, "Person", name = "Bob", age = 22, status = "Married")
charles = createNode(graph, "Person", name = "Charles", age = 25, status = "Unmarried")
```

Delete the `age` property from the `alice` node.

```r
alice = deleteProp(alice, "age")

alice

# Labels: Person
#
# $status
# [1] "Married"
#
# $name
# [1] "Alice"
```

Delete the `name` and `age` properties from the `bob` node.

```r
bob = deleteProp(bob, "name", "age")

bob

# Labels: Person
# 
# $status
# [1] "Married"
```

Delete all properties from the `charles` node.

```r
charles = deleteProp(charles, all = TRUE)

charles

# Labels: Person
```

## See Also

[updateProp](update-prop.html)


