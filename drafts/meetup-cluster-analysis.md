---
title: A Cluster Analysis of London NoSQL Meetup Groups
layout: default
---

# A Cluster Analysis of London NoSQL Meetup Groups

Using [Mark Needham's](markhneedham.com) London NoSQL Meetup groups dataset, I wanted to perform a cluster analysis of the meetup groups based on their shared topics.

After starting the database locally, I explored its structure within my R environment.

```r
library(RNeo4j)

graph = startGraph("http://localhost:7474/db/data/")

summary(graph)

