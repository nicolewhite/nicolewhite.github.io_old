---
layout: rneo4j
---

# Sample Datasets

If you don't have your own data, sample datasets can be loaded through [`populate`](../docs/populate.html). This clears the graph database of all nodes, relationships, constraints, and indices, then populates the database with the sample dataset. You will be prompted to make sure that that is what you want to do.

## Movies

The movie dataset that is available through Neo4j's browser can be loaded with the keyword "movies":

```r
graph = startGraph("http://localhost:7474/db/data/")
populate(graph, "movies")
```

### Database Structure

Executing `summary` on the graph object gives you a high level overview of the structure of the database, and [`getIndex`](../docs/get-index.html) and [`getConstraint`](../docs/get-constraint.html) will tell you if there are any indexes or constraints present:

```r
summary(graph)

#     This       To   That
# 1 Person  FOLLOWS Person
# 2 Person REVIEWED  Movie
# 3 Person DIRECTED  Movie
# 4 Person ACTED_IN  Movie
# 5 Person PRODUCED  Movie
# 6 Person    WROTE  Movie

getIndex(graph)
# No indices in the graph.

getConstraint(graph)
# No constraints in the graph.
```

The node and relationship properties are summarized below.

| Node Label | Node Properties                 |
| ---------- | ------------------------------- |
| Person     | `name`, `born`                  |
| Movie      | `title`,  `tagline`, `released` |

| Relationship Type | Relationship Properties |
| ----------------- | ----------------------- |
| FOLLOWS           | N/A                     |
| REVIEWED          | `rating`, `summary`     |
| DIRECTED          | N/A                     |
| ACTED_IN          | `roles`                 |
| PRODUCED          | N/A                     |
| WROTE             | N/A                     |

### Example

Because an index does not exist, you can't use [`getNodeByIndex`](../docs/get-node-by-index.html) yet. But, you can start retrieving nodes using [`getNodeByCypher`](get-node-by-cypher.html):

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

To search for nodes using [`getNodeByIndex`](../docs/get-node-by-index.html), you need to add an index first. This can be done either with [`addConstraint`](../docs/add-constraint.html) (preferred, because it also adds an index) or [`addIndex`](../docs/add-index.html) (adds an index, but no uniqueness constraint).

```r
addConstraint(graph, "Person", "name")

getConstraint(graph)

#   property_keys  label       type
# 1          name Person UNIQUENESS

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

Let's say we want to add an `age` property to each `Person` node. This will be the current year minus the `born` property. First, get the current year:

```r
year = as.numeric(format(Sys.Date(), "%Y"))
```

Now, we can do this entirely in Cypher...

```r
method1 = function(year) {
  query = "MATCH (p:Person) WHERE p.born IS NOT NULL
           SET p.age = {year} - p.born"
  
  cypher(graph, query, year = year)
}
```

...or through a combination of [`getNodeByIndex`](../docs/get-node-by-index.html) and [`updateProp`](../docs/update-prop.html):

```r
method2 = function(year) {
  query = "MATCH (p:Person) WHERE p.born IS NOT NULL RETURN p.name"
  people = cypher(graph, query)
  
  addAge = function(x) {
    node = getNodeByIndex(graph, "Person", name = x[["p.name"]])
    updateProp(node, age = year - node$born)
  }

  apply(people, 1, addAge)
}
```

The results of the two above methods are identical, but doing things in Cypher is almost always faster:

```r
system.time(method1(year))
# user  system elapsed 
# 0.03    0.00    0.14

system.time(method2(year))
# user  system elapsed 
# 7.17    0.81   10.85
```

## Airline Fleets

A sample dataset of airline fleets can be loaded with the keyword "fleets":

```r
graph = startGraph("http://localhost:7474/db/data/")
populate(graph, "fleets")
```

### Database Structure

Executing `summary()` on the graph object gives you a high level overview of the structure of the database, and `getIndex()` and `getConstraint()` will tell you if there are any indexes or constraints present:

```r
summary(graph)

getIndex(graph)
getConstraint(graph)
```

The node and relationship properties are summarized below.

| Node Label | Node Properties                                        |
| ---------- | ---------------                                        |
| Airline    | `name`*, `status` (Active or Inactive)                 |
| Country    | `name`*                                                |
| Series     | `name`*                                                |
| Model      | `name`*                                                |
| Aircraft   | `msn` (manufacturer's serial number), `ff_day`, `ff_month`, `ff_year` (day, month, year of first flight), `registration` (registration code), `status` (Active, Scrapped, Stored, Written off, On order, or Unknown) |

<nowiki>*</nowiki> There is a uniqueness constraint on this property for the given node label.

None of the relationships in the graph have any properties.

### Example

