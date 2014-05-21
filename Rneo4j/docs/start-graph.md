---
layout: rneo4j
title: startGraph
---

`startGraph`

# Connect to the Database

## Description
Connect to the graph database.

## Usage
`startGraph(url)`

## Arguments
| Parameter | Description |
| --------- | ----------- |
| `url`     | The URL of the graph database. Accepts a string.  |

## Output
A graph object.

## Details
To get started, you will need the URL of your graph database. If you are running Neo4j locally, it is [http://localhost:7474/db/data](http://localhost:7474/db/data).

## Example
```r
graph = startGraph("http://localhost:7474/db/data")
```