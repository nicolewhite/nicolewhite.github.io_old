---
layout: default
title: Why do we divide by n - 1 when calculating the sample variance?
---

### Test!

text text

```python
x = [1,2,3]
```

```r
library(Rneo4j)

graph = startGraph("http://localhost:7474/db/data/")
version(graph)

# Clear the database.
clear(graph)

# Add uniqueness constraint to Person nodes based on the name property.
addUnique(graph, "Person", "name")

# Create nodes for Alice, Bob, and Charles. We forget to assign Charles to a node object,
# but we take care of that later.

# Create nodes with properties.
alice = createNode(graph, c(name = "Alice", age = 20))
bob = createNode(graph, c(name = "Bob", age = 24))

# Create node with properties and Person label.
createNode(graph, c(name = "Charles", age = 19), "Person")

# Nodes can have multiple labels.
addLabel(alice, c("Person", "Student"))
addLabel(bob, "Person")

# Create a [:KNOWS] relationship between Alice and Bob with the given properties.
createRel(alice, "KNOWS", bob, c(since = 2000, through = "School"))

# Retrieve the node object for Charles.
charles = getNode(graph, "MATCH (n:Person {name:'Charles'}) RETURN n")

# To view a node object's properties, execute node$data:
charles$data

# $name
# [1] "Charles"
#
# $age
# [1] 19

# Create a [:KNOWS] relationship between Alice and Charles with the given properties.
rel = createRel(alice, "KNOWS", charles, c(since = 2004, through = "Work"))

# It's Alice's birthday!
alice = updateProps(alice, c(age = 21))

# Delete the "through" property on the relationship between Alice and Charles.
rel = deleteProps(rel, "through")

# Get a dataframe of Cypher query results.
df = cypher(graph, "MATCH n RETURN n.name, n.age")

print(df)
# 	 n.name n.age
# 1   Alice    21
# 2     Bob    24
# 3 Charles    19
```

mathjax maybe

Here is an example MathJax inline rendering \\( 1/x^{2} \\), and here is a block rendering: 
\\[ \frac{1}{n^{2}} \\]
