---
layout: rneo4j
---

# Example

```r
library(Rneo4j)

graph = startGraph("http://localhost:7474/db/data/")

version(graph)
# [1] "2.0.0-RC1"

# Clear the database.
clear(graph)

# Create nodes with labels and properties. I forget to assign Cheer Up Charlie's to a variable,
# but I take care of that later.
mugshots = createNode(graph, "Bar", name = "Mugshots", location = "Downtown")
parlor = createNode(graph, "Bar", name = "The Parlor", location = "Hyde Park")
createNode(graph, "Bar", name = "Cheer Up Charlie's", location = "Downtown")

# Labels can be added after creating the node.
nicole = createNode(graph, name = "Nicole", status = "Student")
addLabel(nicole, "Person")

# Add uniqueness constraints so that Person nodes are unique by name and Bar nodes are unique by name.
addConstraint(graph, "Person", "name")
addConstraint(graph, "Bar", "name")

# View all constraints in the graph.
getConstraint(graph)

#   property_keys  label       type
# 1          name Person UNIQUENESS
# 2          name    Bar UNIQUENESS

# Find Cheer Up Charlie's and assign it to 'charlies':
charlies = getNodeByIndex(graph, "Bar", name = "Cheer Up Charlie's")

# Create relationships.
createRel(nicole, "DRINKS_AT", mugshots, on = "Fridays")
createRel(nicole, "DRINKS_AT", parlor, on = "Saturdays")
createRel(nicole, "DRINKS_AT", charlies, on = "Everyday")

# Get Cypher query results as a data frame.
query  = "MATCH (p:Person {name:'Nicole'})-[d:DRINKS_AT]->(b:Bar)
          RETURN p.name, d.on, b.name, b.location"

cypher(graph, query)

#   p.name      d.on             b.name b.location
# 1 Nicole   Fridays           Mugshots   Downtown
# 2 Nicole Saturdays         The Parlor  Hyde Park
# 3 Nicole  Everyday Cheer Up Charlie's   Downtown

# Add more properties to a node.
nicole = updateProp(nicole, eyes = "green", hair = "blonde")

# Delete properties on a node.
nicole = deleteProp(nicole, "status")

print(nicole)

# Labels: Person
# 
#     name     hair     eyes 
# "Nicole" "blonde"  "green" 
```

# Sample Dataset

If you don't have your own data, the movie database available through Neo4j's browser can be loaded through `populate()`. Using `populate()` clears the graph database of all nodes, relationships, constraints, and indices, then populates the database with the sample dataset. You will be prompted to make sure that that is what you want to do.

```r
graph = startGraph("http://localhost:7474/db/data/")
populate(graph, data = "movies")
```

And now you have the movie database loaded! Printing the graph object gives you a high level overview of the structure of the database, and `getIndex()` and `getConstraint()` will tell you if there are any indices or constraints present:

```r
print(graph)

#     This       To   That
# 1 Person  FOLLOWS Person
# 2 Person REVIEWED  Movie
# 3 Person DIRECTED  Movie
# 4 Person ACTED_IN  Movie
# 5 Person PRODUCED  Movie
# 6 Person    WROTE  Movie

getConstraint(graph)
# No constraints in the graph.

getIndex(graph)
# No indices in the graph.
```

Because an index does not exist, you can't use `getNodeByIndex()` yet. But, you can start retrieving nodes using `getNodeByCypher()`:

```r
query = "MATCH (p:Person {name:'Tom Hanks'}) RETURN p"
tom = getNodeByCypher(graph, query)
print(tom)

# Labels: Person
# 
# $born
# [1] 1956
# 
# $name
# [1] "Tom Hanks"
```

To search for nodes using `getNodeByIndex()`, you need to add an index first. This can be done either with `addConstraint()` (preferred, because it also adds an index) or `addIndex()` (adds an index, but no uniqueness constraint).

```r
addConstraint(graph, "Person", "name")
clint = getNodeByIndex(graph, "Person", name = "Clint Eastwood")
print(clint)

# Labels: Person
# 
# $born
# [1] 1930
# 
# $name
# [1] "Clint Eastwood"
```