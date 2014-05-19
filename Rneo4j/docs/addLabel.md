---
title: addLabel
layout: rneo4j
---

### `addLabel`

#### Description
Add a label or multiple labels to an existing node object.

#### Usage
```r
addLabel(node, ...)
```

#### Arguments
| Parameter | Description |
| --------- | ----------- |
| `node`    | The node object to which to add the label(s). |
| `...`     | The label(s) to add to the node. Accepts a string or strings separated by commas. |

#### Example
```r
addLabel(alice, "Person", "Student")
```

#### See Also
[`getLabel`](get-label.html), [`dropLabel`](drop-label.html)