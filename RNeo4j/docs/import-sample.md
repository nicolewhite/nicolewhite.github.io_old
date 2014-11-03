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

### Available Datasets

| Name | Description |
| ---- | ----------- |
| [tweets](../samples/#Tweets) | Users, tweets, hashtags. |
| [dfw](../samples/#DFW) | Terminals, gates, places. |
| [caltrain](../samples/#Caltrain) | Trains, stops, zones. | 
| [movies](../samples/#Movies) | Movies, actors. |

## Examples

 ```r
graph = startGraph("http://localhost:7474/db/data/")

importSample(graph, "tweets")
summary(graph)
getConstraint(graph)
 ```