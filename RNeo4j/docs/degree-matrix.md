---
title: degreeMatrix
layout: rneo4j
---

# Degree Matrices

## Description

Get a degree matrix for a set of nodes with a specified label, identified by their unique property key, and where degree is defined by the relationship type given. The degree matrix can be direction-agnostic or directed.

## Usage

```r
degreeMatrix(graph, label, key, type, direction = character())
```

## Arguments

| Parameter | Description     |
| --------- | --------------- |
| `graph`   | A graph object. |
| `label`   | A node label. Accepts a string. |
| `key`     | A unique property key by which the nodes will be identified in the degree matrix's rows and columns. Accepts a string. |
| `type`    | A relationship type by which the nodes are tested for degree centrality. Accepts a string. |
| `direction` | An optional direction specifying whether the degree matrix should be direction-agnostic or directed. Accepts a string, either "incoming" or "outgoing". |

## Details

If a direction is not supplied, the `(i, j)` entry of the degree matrix captures how many relationships of type `type` are attached to node `i` regardless of direction. If `direction = "incoming"`, the `(i, j)` entry of the degree matrix captures how many incoming relationships of type `type` are attached to node `i`. If `direction = "outgoing"`, the `(i, j)` entry of the degree matrix captures how many outgoing relationships of type `type` are attached to node `i`.

Degrees are returned as a matrix so that one can easily calculate a [Laplacian matrix](http://en.wikipedia.org/wiki/Laplacian_matrix), \\(L\\), which can be found by \\(L = D - A\\), where \\(D\\) is a degree matrix and \\(A\\) is an adjacency matrix.

## Output
A square, diagonal degree matrix.

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

Get an in-degree matrix.

```r
in_deg = degreeMatrix(graph,
                      label = "Person",
                      key = "name",
                      type = "KNOWS",
                      direction = "incoming")
                      
#         Alex Bob Charles Debby Elaine Forrest
# Alex       1   0       0     0      0       0
# Bob        0   1       0     0      0       0
# Charles    0   0       1     0      0       0
# Debby      0   0       0     2      0       0
# Elaine     0   0       0     0      2       0
# Forrest    0   0       0     0      0       1
```

Get an out-degree matrix.

```r
out_deg = degreeMatrix(graph,
                       label = "Person",
                       key = "name",
                       type = "KNOWS",
                       direction = "outgoing")
                       
#         Alex Bob Charles Debby Elaine Forrest
# Alex       2   0       0     0      0       0
# Bob        0   2       0     0      0       0
# Charles    0   0       1     0      0       0
# Debby      0   0       0     2      0       0
# Elaine     0   0       0     0      1       0
# Forrest    0   0       0     0      0       0
```

Get a direction-agnostic degree matrix.

```r
deg = degreeMatrix(graph,
                   label = "Person",
                   key = "name",
                   type = "KNOWS")
                   
#         Alex Bob Charles Debby Elaine Forrest
# Alex       3   0       0     0      0       0
# Bob        0   3       0     0      0       0
# Charles    0   0       2     0      0       0
# Debby      0   0       0     4      0       0
# Elaine     0   0       0     0      3       0
# Forrest    0   0       0     0      0       1 
```

## See Also

[adjacencyMatrix](adjacency-matrix.html)
