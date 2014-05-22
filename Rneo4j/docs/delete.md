---
title: delete
layout: rneo4j
---

`delete`

# Delete Nodes and Relationships

## Description

Delete node or relationship object(s).

## Usage

```r
delete(...)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `...`     | The node or relationship object(s) to be deleted from the graph database (separated by commas). |

## Details

Nodes with incoming or outgoing relationships cannot be deleted. All incoming and outgoing relationships need to be deleted before the node can be deleted.

## Examples

```r
delete(rel)
delete(alice, bob)
```
