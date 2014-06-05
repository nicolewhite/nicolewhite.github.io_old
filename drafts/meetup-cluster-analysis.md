---
title: A Cluster Analysis of London NoSQL Meetup Groups.
layout: post
comments: true
---

# A Cluster Analysis of London NoSQL Meetup Groups

Using [Mark Needham](http://www.markhneedham.com)'s London NoSQL Meetup groups dataset, I wanted to perform a cluster analysis of the meetup groups based on their shared topics.

After starting the database locally, I explored its structure within my `R` environment. I can view the node labels and how they are connected by executing `summary` on the `graph` object and I can view any uniqueness constraints with [`getConstraint`]({{ site.url }}/RNeo4j/docs/get-constraints.html).

```r
library(RNeo4j)

graph = startGraph("http://localhost:7474/db/data/")

summary(graph)

#             This                   To          That
# 1           Year            HAS_MONTH         Month
# 2          Month              HAS_DAY           Day
# 3            Day                 NEXT           Day
# 4          Group            HAS_TOPIC         Topic
# 5          Group         HOSTED_EVENT         Event
# 6         Person   HAS_MEETUP_PROFILE MeetupProfile
# 7  MeetupProfile            MEMBER_OF         Group
# 8  MeetupProfile            JOINED_ON           Day
# 9  MeetupProfile                RSVPD          RSVP
# 10 MeetupProfile      INITIALLY_RSVPD          RSVP
# 11 MeetupProfile        INTERESTED_IN         Topic
# 12        Person  HAS_TWITTER_ACCOUNT       Twitter
# 13        Person HAS_LINKEDIN_ACCOUNT      LinkedIn
# 14         Event          HAPPENED_ON           Day
# 15         Event              HELD_AT         Venue
# 16         Venue             ALIAS_OF         Venue
# 17          RSVP          HAPPENED_ON           Day
# 18          RSVP                   TO         Event
# 19          RSVP                 NEXT          RSVP

getConstraint(graph)

#   property_keys label       type
# 1            id Topic UNIQUENESS
```

To attempt a cluster analysis on the `Group` nodes based on their shared topics, I want to get a matrix where each observation (or row) represents a group and each column represents a topic, where the `(i, j)` entry of this matrix is binary and indicates whether group `i` has topic `j` (`1` indicates that the group has the topic, `0` otherwise).

To do so, I first write a Cypher query that will get the data in long format.

```r
query = "MATCH (g:Group)-[:HAS_TOPIC]->(t:Topic)
         WHERE t.name <> 'NoSQL'
         RETURN g.name AS group, t.name AS topic, 1 AS hastopic
         ORDER BY group"

group_topics = cypher(graph, query)
```

`group_topics` is a data frame in long format; a snippet is shown below.

<a href="http://i.imgur.com/wTqxx0z.png" target="_blank"><img src="http://i.imgur.com/wTqxx0z.png" width="100%" height="100%"></a>

Because I want a group to uniquely comprise a row, I'll convert the data to wide using [`reshape`](http://had.co.nz/reshape/):

```r
wide = reshape(group_topics, 
			   timevar = "topic", 
			   idvar = "group", 
			   direction = "wide")
```

Each row now indicates which topics a group has.

<a href="http://i.imgur.com/8OwALCz.png" target="_blank"><img src="http://i.imgur.com/8OwALCz.png" width="100%" height="100%"></a>

I need to clean this up a bit by 

* replacing the `NA`s with `0`s
* making the group names the row names
* removing the group names column
* removing the "hastopic." string that now precedes every column name as a result of using `reshape`

```r
wide[is.na(wide)] = 0
rownames(wide) = wide$group
wide = wide[-1]
colnames(wide) = sub("hastopic.", "", colnames(wide))
```

`wide` now looks like this:

<a href="http://i.imgur.com/R8x0cgN.png" target="_blank"><img src="http://i.imgur.com/R8x0cgN.png" width="100%" height="100%"></a>

Now I'm ready to perform the cluster analysis. I decided to use [hierarchical agglomerative clustering](http://en.wikipedia.org/wiki/Hierarchical_clustering) (HAC) using [Ward's](http://en.wikipedia.org/wiki/Ward%27s_method) method, which is simple to do in `R`.

First I need to convert my data frame `wide` into a matrix `mat` and get a dissimilarity matrix `d` using [`dist`](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/dist.html):

```r
mat = as.matrix(wide)
d = dist(mat)
```

`d` is a 35 by 35 dissimilarity matrix, where entry `(i, j)` is the Euclidean distance between group `i` and group `j`.

<a href="http://i.imgur.com/bpddNAT.png" target="_blank"><img src="http://i.imgur.com/bpddNAT.png" width="100%" height="100%"></a>

Then, I can perform the hierarchical clustering with [`hclust`](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/hclust.html):

```r
hc = hclust(d, method = "ward")
```

The algorithm of HAC starts with every entity as its own cluster, then iteratively joins clusters together based on the method chosen (in this case, it is the Ward method) until there is only one cluster (a cluster that contains every entity).

I can view the join history of the HAC algorithm by plotting the `hc` object:

<a href="http://i.imgur.com/UJNql16.png" target="_blank"><img src="http://i.imgur.com/UJNql16.png" width="100%" height="100%"></a>

`plot` actually plots the dendogram vertically, but I cheated and rotated the PDF.

Next, I need to figure out how many clusters I want to keep, or where I want to "cut the tree." The dendogram is often thought of as a tree. Cutting the tree at the red line shown below, for example, would keep two clusters. The groups from Data Science London to HBase London Meetup would be in one cluster and the groups from eXist User Group London to MEAN Stack would be in the other cluster. Moving this red line to the left would cut further up the tree and result in more clusters.

<a href="http://i.imgur.com/c74ZM1r.png" target="_blank"><img src="http://i.imgur.com/c74ZM1r.png" width="100%" height="100%"></a>

To figure out the optimal number of clusters, `k`,  I use the `fpc` package that has a function to do just that, `pamk`:

```r
library(fpc)

k = pamk(mat)$nc

k

# [1] 5
```

Conveniently, there is a function [`cutree`](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/cutree.html) that cuts the `hc` object in order to obtain the number of clusters specified:

```r
group_clusters = cutree(hc, k = k)
```

`group_clusters` is a named integer vector where the names are the group names and the integer is the cluster assignment.

```r
head(group_clusters)

# Big Data / Data Science / Data Analytics Jobs 
# 1 
# Big Data Developers in London 
# 1 
# Big Data Jobs in London 
# 2 
# Big Data London 
# 2 
# Cassandra London 
# 3 
# Couchbase London 
# 1 
```

With this, I want to add the cluster assignments to the graph so that I can run Cypher queries and aggregate them by cluster (a common approach to interpreting the meaning of clusters or defining what the clusters are).

First I need to add a couple uniqueness constraints to the graph with [`addConstraint`]({{ site.url }}/RNeo4j/docs/add-constraint.html) so that I can use the [`getUniqueNode`]({{ site.url }}/RNeo4j/docs/get-unique-node.html) function (and to ensure uniqueness, of course):

```r
addConstraint(graph, "Group", "name")
addConstraint(graph, "Cluster", "id")
```

Next, create the five `Cluster` nodes with [`createNode`]({{ site.url }}/RNeo4j/docs/create-node.html):

```r
lapply(1:k, function(i) createNode(graph, "Cluster", id = i))
```

Create the `(:Group)-[:IN]->(:Cluster)` relationships:

```r
assign_to_clusters = function(i) {
  group = getUniqueNode(graph, "Group", name = names(group_clusters[i]))
  cluster = getUniqueNode(graph, "Cluster", id = group_clusters[[i]])
  createRel(group, "IN", cluster)
}

lapply(1:length(group_clusters), assign_to_clusters)
```

Now each `Group` node is assigned to a cluster.

<a href="http://i.imgur.com/PB7dEKf.png" target="_blank"><img src="http://i.imgur.com/PB7dEKf.png" width="100%" height="100%"></a>

To "paint a picture" of the clusters, I decided to look at the top-occurring words in the group descriptions for each cluster.

For this I'll need the [`getNodes`]({{ site.url }}/RNeo4j/docs/get-nodes.html) function, which allows you to search for nodes with a Cypher query and return a list of `node` objects. Each `Group` node has a `description` property that has its text description.

```r
library(tm)

remove_html = function(s) {
  return(gsub("<.*?>", "", s))
}

query = "MATCH (g:Group)-[:IN]->(:Cluster {id:{clust_id}}) RETURN g"

get_top_words = function(clust_id) {
  groups = getNodes(graph, query, clust_id = clust_id)
  descriptions = lapply(groups, function(g) g$description)
  descriptions = lapply(descriptions, remove_html)
  descriptions = unlist(descriptions)
  
  descrip_corpus = Corpus(VectorSource(descriptions))
  descrip_corpus = tm_map(descrip_corpus, removePunctuation)
  descrip_corpus = tm_map(descrip_corpus, tolower)
  descrip_corpus = tm_map(descrip_corpus, function(d) removeWords(d, c(stopwords("english"), "data", "nosql")))
  
  tdm = TermDocumentMatrix(descrip_corpus)
  m = as.matrix(tdm)
  v = sort(rowSums(m),decreasing = TRUE)
  
  print(paste0("Top 5 words for cluster ", clust_id, "."))
  cat("\n")
  print(v[1:5])
  cat("\n")
}

lapply(1:k, get_top_words)

# [1] "Top 5 words for cluster 1."
# 
# big analytics     group   science      will 
#  14         9         8         8         6 
# 
# [1] "Top 5 words for cluster 2."
# 
# big     people     hadoop interested       join 
#  15          8          6          6          5 
# 
# [1] "Top 5 words for cluster 3."
# 
# meetup  group search london   meet 
#     10      9      7      6      6 
# 
# [1] "Top 5 words for cluster 4."
# 
# graph   databases    database distributed       neo4j 
#     7           4           3           3           3 
# 
# [1] "Top 5 words for cluster 5."
# 
# marklogic community     group   meetups       xml 
#         5         3         3         3         3 
```

With this, we might say Cluster 1 can be described as a data science / analytics cluster, Cluster 2 a 'big data' cluster, Cluster 3 a general NoSQL cluster, Cluster 4 a graph database cluster, and Cluster 5 an XML-based database cluster.