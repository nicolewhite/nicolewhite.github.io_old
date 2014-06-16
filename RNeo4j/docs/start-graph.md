---
title: startGraph
layout: rneo4j
---

`startGraph`

# Connect to the Graph Database

## Description

Establish a connection to the graph database.

## Usage

`startGraph(url)`

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `url`     | The URL of the graph database. Accepts a string.  |

## Output

A graph object.

## Details

To get started, you will need the URL of the graph database. If running Neo4j locally, it is `http://localhost:7474/db/data/`.

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
```