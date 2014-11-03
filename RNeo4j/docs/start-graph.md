---
title: startGraph
layout: rneo4j
---

# Connect to the Database

## Description

Establish a connection to the graph database.

## Usage

```r
startGraph(url, username = character(), password = character())
```

## Arguments

| Parameter | Description |
| --------- | ----------- |
| `url`     | The URL of the graph database. Accepts a string.  |
| `username` | If the database is remote, your username. Accepts a string. |
| `password` | If the database is remote, your password. Accepts a string. |

## Value

A graph object.

## Examples

```r
# A local db.
graph = startGraph("http://localhost:7474/db/data/")

# A remote graphene db.
graph = startGraph(url = "http://test.sb02.stations.graphenedb.com:24789/db/data/", 
				   username = "test", 
				   password = "ftDPkChL641gBe5s9xBO")
```