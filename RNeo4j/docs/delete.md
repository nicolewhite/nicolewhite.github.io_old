---
title: delete
layout: rneo4j
---

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
| `...`     | Node or relationship object(s) to be deleted from the graph database (separated by commas). |

## Details

Nodes with incoming or outgoing relationships cannot be deleted. All incoming and outgoing relationships need to be deleted before the node can be deleted.

## Examples

```r
alice = createNode(graph, name = "Alice")
bob = createNode(graph, name = "Bob")

rel = createRel(alice, "WORKS_WITH", bob)

delete(rel)
delete(alice, bob)
```
