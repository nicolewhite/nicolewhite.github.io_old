---
layout: rneo4j
---

# Sample Datasets

Four sample datasets ship with this package. They can be imported with [importSample](../docs/import-sample.html). This page details the model for each dataset, then showcases example analyses.

<a name="Tweets"></a>
## Tweets

### Data Model

<a href="http://i.imgur.com/6qILRNI.png" target="_blank"><img src="http://i.imgur.com/6qILRNI.png" width="100%" height="100%"></a>

### Example

```r
graph = startGraph("http://localhost:7474/db/data/")
importSample(graph, "tweets")

# View neo4j's tweets.
neo4j = getUniqueNode(graph, "User", screen_name = "neo4j")
sapply(lapply(outgoingRels(neo4j, "POSTS"), endNode), function(t) t$text)

# Top mentioned users.
query = "
MATCH (:Tweet)-[:MENTIONS]->(u:User)
RETURN u.screen_name AS user, COUNT(*) AS mentions
ORDER BY mentions DESC
LIMIT 10
"

cypher(graph, query)
```

<a name="DFW"></a>
## Dallas / Forth-Worth International Airport (DFW)

### Data Model

<a href="http://i.imgur.com/mkDMV27.png" target="_blank"><img src="http://i.imgur.com/mkDMV27.png" width="100%" height="100%"></a>

### Example

```r
graph = startGraph("http://localhost:7474/db/data/")
importSample(graph, "dfw")

# All places and their names.
places = getLabeledNodes(graph, "Place")
sapply(places, function(p) p$name)

# Get all pathways of places in terminal A.
query = "
MATCH p = (:Place)-[:AT_GATE]->(:Gate)-[:IN_TERMINAL]->(t:Terminal)
WHERE t.name = 'A'
RETURN p
"

p = getPaths(graph, query)
n = lapply(p, nodes)

coalesce <- function(a, b) {
  if(!is.null(a)) {
    return(a)
  } else if(!is.null(b)) {
    return(b)
  } else{
    return(NULL)
  }
}

sapply(n, function(x) sapply(x, function(y) coalesce(y$name, y$gate)))
```

<a name="Caltrain"></a>
## Caltrain

### Data Model

<a href="http://i.imgur.com/KlgSEh5.png" target="_blank"><img src="http://i.imgur.com/KlgSEh5.png" width="100%" height="100%"></a>

### Example

```r
graph = startGraph("http://localhost:7474/db/data/")
importSample(graph, "caltrain")

# Shortest path from San Francisco to San Mateo 
# by traversing the NEXT relationship between Stop nodes.
sf = getUniqueNode(graph, "Stop", name = "SAN FRANCISCO")
sm = getUniqueNode(graph, "Stop", name = "SAN MATEO")

p = shortestPath(sf, "NEXT", sm, max_depth = 10)
nodes(p)

# Distance between San Francisco and San Mateo.
paste(sm$mile - sf$mile, "miles between", sf$name, "and", sm$name)

# Trains to take home to San Mateo from San Francisco
# after 7:00 PM (19:00) on a weekday.

query = "
MATCH (t:Train)
WHERE t.direction = 'Southbound' AND t.type = 'Weekday'
WITH t

MATCH (t)-[leave:STOPS_AT]->(begin:Stop),
      (t)-[:STOPS_AT]->(end:Stop)
WHERE begin.name = 'SAN FRANCISCO' AND
      end.name = 'SAN MATEO'
WITH t, leave.hour*100 + leave.minute AS hundreds, leave.hour_s AS Hour, leave.minute_s AS Minute
WHERE hundreds > 1900 OR hundreds < 100
RETURN t.id AS Train, Hour + ':' + Minute AS `Departure Time`
"

cypher(graph, query)
```

<a name="Movies"></a>
## Movies

### Data Model

<a href="http://i.imgur.com/mvL0sLM.png" target="_blank"><img src="http://i.imgur.com/mvL0sLM.png" width="100%" height="100%"></a>

### Example

```r
graph = startGraph("http://localhost:7474/db/data/")
importSample(graph, "movies")

# Find the oldest person and their age.
oldest = getSingleNode(graph, "MATCH (p:Person) WITH p ORDER BY p.born LIMIT 1 RETURN p")
as.numeric(format(Sys.Date(), '%Y')) - oldest$born

# Matrix actors.
query = "
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.title =~ {regex}
RETURN DISTINCT p.name AS actor
"

cypher(graph, query, regex = ".*Matrix.*")

# Emil? Who's that? Let's delete him.
emil = getUniqueNode(graph, "Person", name = "Emil Eifrem")
lapply(outgoingRels(emil), delete)
lapply(incomingRels(emil), delete)
delete(emil)

cypher(graph, query, regex = ".*Matrix.*")
```
