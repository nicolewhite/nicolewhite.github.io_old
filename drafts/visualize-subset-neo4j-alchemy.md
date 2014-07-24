---
title: Cluster and Visualize a Subset of Your Neo4j Database in RNeo4j and Alchemy.js.
layout: post
comments: true
---

# Cluster and Visualize a Subset of Your Neo4j Database Using RNeo4j and Alchemy.js.

Neo4j partner [Graph Alchemist](http://www.graphalchemist.com/) has open sourced a visualization library called [Alchemy.js](http://graphalchemist.github.io/Alchemy/#/) that's built in d3. It addresses the many issues with construcing a d3 force-directed graph, allowing for easier customization and a more intuitive way to pass in the JSON data.

The Neo4j database I am working with is simple: there are `(:Authors)` and `(:Articles)`, and an `(:Author)-[:WROTE]->(:Article)` relationship exists if the author was a contributing author of the article. This is all in the context of articles on ovarian cancer collected from PUBMED. From this structure, I want to visualize co-authorship and identify clusters of expertise among authors in this field.

Alchemy's visualization accepts graphJSON as input data and also supports coloring nodes by an assigned cluster, so I'll use RNeo4j to query the data from Neo4j, run a clustering algorithm, and convert the results to graphJSON.

First, I connect to the locally-hosted database and sample 700 authors (there are around 4000 total authors, which is too busy to visualize). I use [getLabeledNodes](http://nicolewhite.github.io/RNeo4j/docs/get-labeled-nodes.html) to get all `(:Author)` nodes into a list of node objects called `authors`, then I use `sapply` to extract their names into a character vector called `authors_names`. I then use `sample` to sample 700 names from this vector.

```r
neo4j = startGraph("http://localhost:7474/db/data/")

SAMPLE_SIZE = 700
authors = getLabeledNodes(neo4j, "Author")
authors_names = sapply(authors, function(a) a$name)
authors_sample = sample(authors_names, SAMPLE_SIZE, replace = FALSE)
```

With my sample defined, I can now pass it as a parameter into my Cypher queries to only select authors that are in my sample.

```r
nodes_query = "
MATCH (a:Author)
WHERE a.name IN {sample}
RETURN ID(a) AS id, a.name AS name
"

edges_query = "
MATCH (a:Author)
WHERE a.name IN {sample}

WITH COLLECT(a) AS authors
UNWIND authors AS a1
UNWIND authors AS a2

MATCH (a1)-[:WROTE]->(:Article)<-[:WROTE]-(a2)
WHERE ID(a1) < ID(a2)
RETURn ID(a1) AS source, ID(a2) AS target
"

nodes = cypher(neo4j, nodes_query, sample = authors_sample)
edges = cypher(neo4j, edges_query, sample = authors_sample)
```

```r
> head(nodes)
     id             name
1  7476     Junying Wang
2  7932        Mei Zhong
3  9229     Shangnong Wu
4  7487    Steven M Dunn
5  8175     Rudolf Kaaks
6 10382 Nicole D Fleming
```

```r
> head(edges)
  source target
1   7476   7487
2   7476   7486
3   7476   7491
4   7476   7498
5   7476   7495
6   7476   7496
```

If I didn't care about clustering, I could convert `nodes` and `edges` to JSON right now and that would be enough to visualize my graph using alchemy.js. But, I want to color my nodes by some meaningful cluster assignment, so I pass my data into [igraph](http://igraph.org/r/doc/igraph.pdf) so that I can run the [Girvan-Newman edge betweenness clustering algorithm](http://www.pnas.org/content/99/12/7821.full).

```r
ig = graph.data.frame(edges, directed = FALSE, nodes)
communities = edge.betweenness.community(ig)
memb = data.frame(name = communities$names, cluster = communities$membership)
nodes = merge(nodes, memb)
nodes = nodes[c("id", "name", "cluster")]
```

The cluster assignments are now a column in the `nodes` data frame.

```r
> head(nodes)
     id      name cluster
1  9022  A Armuss      57
2 10054   A Brand      44
3  7838  A Casado      47
4 10062 A Crandon      44
5  8447  A Fasolo       9
6  9391    A Feki      40
```

Now I need to convert both `nodes` and `edges` to JSON and save them to a `.json` file.

```r
nodes_json = paste0("{\"nodes\":", jsonlite::toJSON(nodes))
edges_json = paste0("\"edges\":", jsonlite::toJSON(edges), "}")
all_json = paste0(nodes_json, ",", edges_json)

sink(file = 'doctors.json')
cat(all_json)
sink()
```

My JSON file `doctors.json` looks like this:

```
{
   "nodes":[
      {
         "id":9347,
         "name":"A B Guzel",
         "cluster":49
      },
      {
         "id":7613,
         "name":"A B Versluys",
         "cluster":50
      },

      ...

      {
         "id":9160,
         "name":"Zuzana Jendželovská",
         "cluster":40
      }
   ],
   "edges":[
      {
         "source":7476,
         "target":7487
      },
      {
         "source":7476,
         "target":7486
      },

      ...

      {
         "source":10412,
         "target":10418
      }
   ]
}
```

I point to `doctors.json` for my `dataSource` parameter in `graph.html` and set a few other parameters that are detailed in the alchemy.js [configuration docs](http://graphalchemist.github.io/Alchemy/documentation/Configuration/):

```html
<html>
<head>
<link rel="stylesheet" href="http://cdn.graphalchemist.com/alchemy.min.css">
</head>
  <body>
    <div class="alchemy" id="alchemy"></div>
    <script src="http://cdn.graphalchemist.com/alchemy.min.js"></script>
    <script type="text/javascript">
        alchemy.begin({
        	dataSource: "doctors.json", 
        	nodeCaption: 'name', 
        	nodeMouseOver: 'name',
            cluster: true,
        	clusterColours: ["#FF0000", "#FF0E00", "#FF1C00", "#FF2A00", "#FF3800", "#FF4600", "#FF5400", "#FF6200", "#FF7000", "#FF7F00", "#FF8F00", "#FF9F00", "#FFAF00", "#FFBF00", "#FFCF00", "#FFDF00", "#FFEF00", "#FFFF00", "#DFFF00", "#BFFF00", "#9FFF00", "#7FFF00", "#5FFF00", "#3FFF00", "#1FFF00", "#00FF00", "#00DF1F", "#00BF3F", "#009F5F", "#007F7F", "#005F9F", "#003FBF", "#001FDF", "#0000FF", "#0900EF", "#1200DF", "#1C00D0", "#2500C0", "#2E00B0", "#3800A1", "#410091", "#4B0082", "#530091", "#5C00A1", "#6400B0", "#6D00C0", "#7500D0", "#7E00DF", "#8600EF", "#8F00FF"]})
    </script>
  </body>
</html>
```

Finally, I can view my graph by navigating in the terminal to the directory where `doctors.json` and `graph.html` sit and using Python's SimpleHTTPServer module:

```
python -m SimpleHTTPServer
```

This will return `Serving HTTP on 0.0.0.0 port 8000 ...`, making it so I can view my graph at http://localhost:8000/graph.html.

<a href="http://i.imgur.com/U0KYAT1.jpg" target="_blank"><img src="http://i.imgur.com/U0KYAT1.jpg" width="100%" height="100%"></a>

Full code (including data collection and database creation) is [here](https://github.com/nicolewhite/pubmed_author_graph).
