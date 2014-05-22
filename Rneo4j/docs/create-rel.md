---
title: createRel
layout: rneo4j
---

`createRel`

# Create Relationships

## Description
Create a relationship between two nodes with the given type and properties.

## Usage

```r
createRel(fromNode, type, toNode, ...)
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `fromNode` | The node object from which the relationship will be outgoing. |
| `type` | The type of relationship. Accepts a string (see details). |
| `toNode` | The node object to which the relationship will be incoming. |
| `...` | Optional relationship properties in the form key = value. |

## Output

A relationship object.

## Details

The string supplied for the `type` argument will be converted to uppercase and all spaces will be replaced with underscores. That is,

```r
createRel(alice, "works with", bob)
```

is equivalent to

```r
createRel(alice, "WORKS_WITH", bob)
```

## Examples

Relationship without properties.

```r
rel = createRel(alice, "works with", bob)
```

Relationship with properties.

```r
rel = createRel(alice, "works with", charles, since = 2000, through = "Work")
```

## See Also
[`getStart`](get-start.html), [`getEnd`](get-end.html)