---
title: startGraph
layout: rneo4j
---

# Connect to the Database

## Description

Establish a connection to the graph database.

## Usage

```r
startGraph(url,
		   username = character(),
		   password = character(),
		   opts = list())
```

## Arguments

| Parameter    | Description |
| ------------ | ----------- |
| `url`        | The URL of the graph database. Accepts a string.  |
| `username`   | If the database is remote, your username. Accepts a string. |
| `password`   | If the database is remote, your password. Accepts a string. |
| `opts`       | Optional HTTP settings. |

## Value

A graph object.

## Examples

```r
# A Neo4j <= 2.1 db.
graph = startGraph("http://localhost:7474/db/data/")

# A Neo4j >= 2.2 db.
graph = startGraph("http://localhost:7474/db/data/",
                   username = "neo4j",
                   password = "password")

# Set a timeout of 3 seconds.
graph = startGraph("http://localhost:7474/db/data/",
                   opts = list(timeout=3))

```
