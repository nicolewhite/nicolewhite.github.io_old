---
layout: default
title: startGraph()
---

# Connect to the graph database.

### `startGraph()`

#### Usage
`startGraph(url)`

#### Arguments
`url`    A string.

#### Output
A graph object.

#### Details
To get started, you will need the URL of your graph database. If you are running Neo4j locally, it is [http://localhost:7474/db/data](http://localhost:7474/db/data).

#### Example
```r
graph = startGraph("http://localhost:7474/db/data")
```

