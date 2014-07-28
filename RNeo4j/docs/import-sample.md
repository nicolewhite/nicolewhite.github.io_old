---
title: importSample
layout: rneo4j
---

# Import Sample Datasets

## Description

Import example datasets supplied with this package.

## Usage

```r
importSample(graph, data)
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

## Examples

 ```r
 importSample(graph, "movies")
 ```