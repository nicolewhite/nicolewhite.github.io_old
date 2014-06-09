---
title: adjacencyMatrix
layout: rneo4j
---

# Adjacency Matrices

## Description

Get an adjacency matrix for a set of nodes with a specified label, identified by their unique property key, and where adjacency is defined by the relationship type given. The adjacency matrix can be direction-agnostic or directed.

## Usage

```r
adjacencyMatrix(graph, label, key, type, direction = character())
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | A node label. Accepts a string. |
| `key`     | A unique property key by which the nodes will be identified in the adjacency matrix's rows and columns. Accepts a string. |
| `type`    | A relationship type by which the nodes are tested for adjacency. Accepts a string. |
| `direction` | An optional direction specifying whether the adjacency matrix should be direction-agnostic or directed. Accepts a string, either "incoming" or "outgoing". |

## Details

If a direction is not supplied, the `(i, j)` entry of the adjacency matrix will capture whether or not a relationship of type `type` exists between node `i` and node `j` regardless of direction. If `direction = "incoming"`, the `(i, j)` entry of the adjacency matrix will capture whether or not there is an incoming relationship of type `type` to node `i` from node `j`. If `direction = "outgoing"`, the `(i, j)` entry of the adjacency matrix will capture whether or not there is an outgoing relationship of type `type` from node `i` to node `j`.

An adjacency matrix with `direction = "incoming"` is equal to the transpose of an adjacency matrix with `direction = "outgoing"` and vice versa, all else held constant.

## Value

A square adjacency matrix. If a direction is not supplied, the matrix will be symmetric. Otherwise, it will be asymmetric.

## Examples

```r
addConstraint(graph, "Person", "name")

alice = createNode(graph, "Person", name = "Alex")
bob = createNode(graph, "Person", name = "Bob")
charles = createNode(graph, "Person", name = "Charles")
debby = createNode(graph, "Person", name = "Debby")
elaine = createNode(graph, "Person", name = "Elaine")
forrest = createNode(graph, "Person", name = "Forrest")

createRel(alice, "KNOWS", bob)
createRel(alice, "KNOWS", elaine)
createRel(bob, "KNOWS", elaine)
createRel(bob, "KNOWS", charles)
createRel(charles, "KNOWS", debby)
createRel(debby, "KNOWS", alice)
createRel(debby, "KNOWS", forrest)
createRel(elaine, "KNOWS", debby)
```

Get a directed adjacency matrix of outgoing `KNOWS` relationships.

```r
out_adj = adjacencyMatrix(graph, 
                          label = "Person",
                          key = "name",
                          type = "KNOWS",
                          direction = "outgoing")
                          
out_adj

#         Alex Bob Charles Debby Elaine Forrest
# Alex       0   1       0     0      1       0
# Bob        0   0       1     0      1       0
# Charles    0   0       0     1      0       0
# Debby      1   0       0     0      0       1
# Elaine     0   0       0     1      0       0
# Forrest    0   0       0     0      0       0
```

Get a directed adjacency matrix of incoming `KNOWS` relationships.

```r
in_adj = adjacencyMatrix(graph, 
                         label = "Person",
                         key = "name",
                         type = "KNOWS",
                         direction = "incoming")
                         
in_adj

#         Alex Bob Charles Debby Elaine Forrest
# Alex       0   0       0     1      0       0
# Bob        1   0       0     0      0       0
# Charles    0   1       0     0      0       0
# Debby      0   0       1     0      1       0
# Elaine     1   1       0     0      0       0
# Forrest    0   0       0     1      0       0
```

The incoming relationship matrix is equal to the transpose of the outgoing adjacency matrix and vice versa.

```r
identical(in_adj, t(out_adj))

# [1] TRUE

identical(out_adj, t(in_adj))

# [1] TRUE
```

Get a direction-agnostic adjacency matrix of `KNOWS` relationships.

```r
adj = adjacencyMatrix(graph, 
                      label = "Person",
                      key = "name",
                      type = "KNOWS")
                      
adj

#         Alex Bob Charles Debby Elaine Forrest
# Alex       0   1       0     1      1       0
# Bob        1   0       1     0      1       0
# Charles    0   1       0     1      0       0
# Debby      1   0       1     0      1       1
# Elaine     1   1       0     1      0       0
# Forrest    0   0       0     1      0       0
```

## See Also

[degreeMatrix](degree-matrix.html)