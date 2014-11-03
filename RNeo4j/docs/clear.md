---
title: clear
layout: rneo4j
---

# Clear the Database

## Description

Delete all nodes, relationships, constraints, and indexes from the graph database. Requires answering a prompt.

## Usage

```r
clear(graph, input = TRUE)
```

## Arguments

| Parameter | Description | 
| --------- | ----------- |
| `graph`   | The graph object to be cleared. |
| `input`   | Whether or not confirmation (in the form of external input) from the user should be required. |

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)
```