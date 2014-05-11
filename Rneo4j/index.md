---
layout: rneo4j
---
        
# Installation

## Install & Start Neo4j

The community edition of Neo4j can be installed on Windows, Mac, or Linux. All releases can be found [here](http://www.neo4j.org/download/other_versions). However, only versions 2.0 and above are compatible with Rneo4j.

Details on installing and starting Neo4j for each operating system:

* [Windows](http://docs.neo4j.org/chunked/stable/server-installation.html#windows-install)
* [Linux](http://docs.neo4j.org/chunked/stable/server-installation.html#linux-install)
* [Mac OSX](http://docs.neo4j.org/chunked/stable/server-installation.html#osx-install)

## Install Rneo4j

In your `R` environment, execute the following:

```r
install.packages("devtools")
devtools::install_github("nicolewhite/Rneo4j")
library(Rneo4j)
```