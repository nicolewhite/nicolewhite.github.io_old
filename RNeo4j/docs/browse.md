---
title: browse
layout: rneo4j
---

# Open the Neo4j Browser

## Description

Open the Neo4j browser.

## Usage

```r
browse(graph, viewer = TRUE)
```

## Arguments

| Parameter | Description | 
| --------- | ----------- |
| `graph`   | A graph object. |
| `viewer`  | Logical, whether to view in IDE's viewer pane. |

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
browse(graph)
```