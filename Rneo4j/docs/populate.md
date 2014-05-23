---
title: populate
layout: rneo4j
---

`populate`

# Populate the Graph Database

## Description

Populate the graph database with example datasets supplied with this package.

## Usage

```r
populate(graph, data)
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `data`    | The dataset to be imported. Accepts a string. |

## Details

Available Datasets

| Name | Description | Size |
| ---- | ----------- | ---- |
| "movies" | Graph of movies, actors. | 19.55 MB |
| "fleets" | Graph of airlines, aircraft. | fdsa |

## Examples

 ```r
 populate(graph, "movies")
 ```