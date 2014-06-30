---
title: Calculate PageRank in a Graph of Webpages.
layout: post
comments: true
category: R
---

# Calculate PageRank in a Graph of Webpages

When you search for something on Google, the webpages containing your keyword search are ordered by their pagerank. Finding a webpage's pagerank can be done by thinking of the Internet as a directed graph, where each webpage is a node and the edges indicate links between webpages. Pagerank can then be calculated by treating this graph as a Markov process, where each node is a state and its edges to other nodes determine the probability that the user moves from one state to the next. Pagerank is simply the steady-state distribution of this Markov process.

I have a Neo4j database of a handful of Wikipedia webpages. The structure is simple: There are `(:Page)` nodes and directed `[:LINKS_TO]` relationships indicating if a `(:Page)` links to another `(:Page)`:

PIC OF STRUCTURE HERE

