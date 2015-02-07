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
		   auth_token = character(),
		   opts = list())
```

## Arguments

| Parameter    | Description |
| ------------ | ----------- |
| `url`        | The URL of the graph database. Accepts a string.  |
| `username`   | If the database is remote, your username. Accepts a string. |
| `password`   | If the database is remote, your password. Accepts a string. |
| `auth_token` | If on Neo4j 2.2 and above, your authentication token. Accepts a string. |
| `opts`       | Optional HTTP settings. |

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

# A Neo4j 2.2 db.
graph = startGraph("http://localhost:7474/db/data/", 
                   auth_token = "3378f3296094b4e1f7c33dc4287ad757")

# Set a timeout of 3 seconds.
graph = startGraph(url = "http://localhost:7474/db/data/", 
              	   opts = list(timeout=3))
```