---
title: browse
layout: rneo4j
---

# Open the Neo4j Browser

## Description

Open the Neo4j browser in the default web browser.

## Usage

```r
browse(graph)
```

## Arguments

| Parameter | Description | 
| --------- | ----------- |
| `graph`   | A graph object. |

## Examples

```r
graph = startGraph("http://localhost:7474/db/data/")
browse(graph)
```