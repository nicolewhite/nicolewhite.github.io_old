---
title: Cluster and Visualize a Subset of Your Neo4j Database Using RNeo4j, igraph, and Alchemy.js.
layout: post
comments: true
---

# Cluster and Visualize a Subset of Your Neo4j Database Using RNeo4j, igraph, and Alchemy.js.

Neo4j technology partner [Graph Alchemist](http://www.graphalchemist.com/) has open sourced a visualization library called [Alchemy.js](http://graphalchemist.github.io/Alchemy/#/) that's built in d3. It addresses the many issues with construcing a d3 force-directed graph, allowing for easier customization and a more intuitive way to pass in the JSON data.

Alchemy's visualization accepts [GraphJSON](http://graphalchemist.github.io/Alchemy/documentation/GraphJSON/) as input data and also supports coloring nodes by an assigned cluster, so I'll use [RNeo4j](/RNeo4j) to query the data from Neo4j, [igraph](http://igraph.org/r/) to run the clustering algorithm, and [jsonlite](http://cran.r-project.org/web/packages/jsonlite/vignettes/json-mapping.pdf) to convert the results to GraphJSON.

To demonstrate these tools, I'll be using the sample movie dataset that ships with Neo4j. You can load this dataset within the Neo4j browser, but I've also included a function within my R package to do so:

```r
library(RNeo4j)
neo4j = startGraph("http://localhost:7474/db/data/")
importSample(neo4j, "movies")
```

This will clear your database and import the sample movie dataset, and you will be prompted to make sure that that is what you want to do. You can explore the structure of your database by executing `summary` on the graph object `neo4j`:

```r
> summary(neo4j)
    This       To   That
1 Person ACTED_IN  Movie
2 Person DIRECTED  Movie
3 Person PRODUCED  Movie
4 Person    WROTE  Movie
5 Person  FOLLOWS Person
6 Person REVIEWED  Movie
```

As implied in the title of this post, I only want to visualize a subset of my dataset. Here, I've decided that I want to look at actors who have worked together on the same movie. This relationship does not directly exist in the database, but I can infer the relationship with Cypher and make it so actors who have worked together on the same movie are connected in my visualization.

```r
nodes_query = "
MATCH (a:Person)-[:ACTED_IN]->(:Movie)
RETURN DISTINCT ID(a) AS id, a.name AS name
"

edges_query = "
MATCH (a1:Person)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(a2:Person)
RETURN ID(a1) AS source, ID(a2) AS target
"

nodes = cypher(neo4j, nodes_query)
edges = cypher(neo4j, edges_query)
```

```r
> head(nodes)
  id               name
1  1       Keanu Reeves
2  2   Carrie-Anne Moss
3  3 Laurence Fishburne
4  4       Hugo Weaving
5  8        Emil Eifrem
6 12    Charlize Theron

> head(edges)
  source target
1      1      2
2      1      3
3      1      4
4      1      8
5      1      2
6      1      3
```

If I didn't care about clustering, I could convert `nodes` and `edges` to GraphJSON right now and that would be enough to visualize my graph using Alchemy.js:

<a href="http://nicolewhite.github.io/examples/alchemy/graph_nocluster.html" target="_blank"><img src="http://i.imgur.com/XdOWIaP.png" width="100%" height="100%"></a>
**Click picture to go to live visualization.**


But, I want to color the nodes by some meaningful cluster assignment. To identify these clusters, I'll use the [Girvan-Newman edge betweenness clustering algorithm](http://www.pnas.org/content/99/12/7821.full), which is easy with igraph's [edge.betweenness.community](http://igraph.org/r/doc/community.edge.betweenness.html) function. Conveniently, my `nodes` and `edges` data frames are not only ready for conversion to GraphJSON, but they are also in the format needed for creating an igraph graph object using [graph.data.frame](http://igraph.org/r/doc/graph.data.frame.html).

```r
library(igraph)

# Create igraph graph object.
ig = graph.data.frame(edges, directed = FALSE, nodes)

# Run Girvan-Newman clustering algorithm.
communities = edge.betweenness.community(ig)

# Extract cluster assignments and merge with nodes data.frame.
memb = data.frame(name = communities$names, cluster = communities$membership)
nodes = merge(nodes, memb)

# Reorder columns.
nodes = nodes[c("id", "name", "cluster")]
```

The cluster assignments are now a column in the `nodes` data frame.

```r
> head(nodes)
   id              name cluster
1  28      Aaron Sorkin       2
2  13         Al Pacino       1
3  57 Annabella Sciorra       4
4  32   Anthony Edwards       3
5 111     Audrey Tautou       3
6 118         Ben Miles       5
```

Now I need to convert both `nodes` and `edges` to GraphJSON and save them to a `.json` file, which is easy with jsonlite's `toJSON`.

```r
nodes_json = paste0("\"nodes\":", jsonlite::toJSON(nodes))
edges_json = paste0("\"edges\":", jsonlite::toJSON(edges))
all_json = paste0("{", nodes_json, ",", edges_json, "}")

sink(file = 'actors.json')
cat(all_json)
sink()
```

The file `actors.json` looks like this:

```
{  
   "nodes":[  
      {  
         "id":28,
         "name":"Aaron Sorkin",
         "cluster":2
      },
      {  
         "id":13,
         "name":"Al Pacino",
         "cluster":1
      },

      ...

      {
         "id":94,
         "name":"Zach Grenier",
         "cluster":3
      }
   ],
   "edges":[
      {
         "source":1,
         "target":2
      },
      {
         "source":1,
         "target":3
      },

      ...

      {
         "source":163,
         "target":144
      }
   ]
}
```

I point to `actors.json` for my `dataSource` parameter in `graph.html` and set a few other parameters that are detailed in the Alchemy.js [configuration docs](http://graphalchemist.github.io/Alchemy/documentation/Configuration/):

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
        	dataSource: "actors.json", 
        	nodeCaption: 'name', 
        	nodeMouseOver: 'name',
            cluster: true,
            clusterColours: ["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02"]})
    </script>
  </body>
</html>
```

Finally, I can view my graph visualization by navigating in the terminal to the directory where `actors.json` and `graph.html` sit and executing Python's SimpleHTTPServer module:

```
python -m SimpleHTTPServer
```

This will return `Serving HTTP on 0.0.0.0 port 8000 ...`, making it so I can view my graph at `http://localhost:8000/graph.html`.

<a href="http://nicolewhite.github.io/examples/alchemy/graph.html" target="_blank"><img src="http://i.imgur.com/yOMjiiE.png" width="100%" height="100%"></a>
**Click picture to go to live visualization.**

We can see that the clustering algorithm identified five clusters, and the layout of the visualization shows nodes in the same cluster closer together. The full code for this project is [on GitHub](https://github.com/nicolewhite/actor_cluster_alchemy).
