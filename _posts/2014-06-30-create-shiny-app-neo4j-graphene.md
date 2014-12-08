---
title: Create a Shiny App Powered by a Neo4j Database.
layout: post
comments: true
category: R
---

# Create a Shiny App Powered by a Neo4j Database.

[Shiny](http://shiny.rstudio.com/) is my new favorite thing from RStudio. It's a web framework for R, which is nice for someone like me with little web development experience. The tutorial and gallery pages are a good place to start.

At its most basic, a Shiny app consists of a `ui.R` file and a `server.R` file in the same directory, which was all that I needed to create [this app](https://nicolewhite.shinyapps.io/dfw_app/). You can use any R package that is on CRAN or GitHub in Shiny, so I am able to use RNeo4j to connect to a Neo4j database within my app.

I have a small database of Dallas Fort-Worth Airport (DFW) restaurants stored in Neo4j. It has the following structure:

```
   This          To     That
1  Gate IN_TERMINAL Terminal
2 Place IN_CATEGORY Category
3 Place     AT_GATE     Gate
```

For example, here is a visualization of terminal A:

<a href="http://i.imgur.com/U9SPDyM.png" target="_blank"><img src="http://i.imgur.com/U9SPDyM.png" width="100%" height="100%"></a>

The DFW data ships as a sample dataset with RNeo4j, so you can import it with [importSample]({{ site.url }}/RNeo4j/docs/import-sample.html):

```r
library(RNeo4j)
graph = startGraph("http://localhost:7474/db/data/")
importSample(graph, "dfw")
```

For my app, I simply wanted to be able to select an arbitrary number of restaurant categories in a certain terminal and order the results by absolute distance from a given gate number. This is really easy to do with the Shiny widgets, whose selections I pass as parameters to a Cypher query.

Before developing, you'll need to install the `shiny` package with:

```r
install.packages("shiny")
```

Below are my `ui.R` and `server.R` files, which are pretty easy to follow once you've read through the [Shiny tutorial](http://shiny.rstudio.com/tutorial/).

`ui.R`

```r
library(shiny)
library(RNeo4j)

# Connect to the Neo4j DB.
graph = startGraph("http://localhost:7474/db/data/")

# Get categories and terminals.
categories = getLabeledNodes(graph, "Category")
categories = sapply(categories, function(c) c$name)

terminals = getLabeledNodes(graph, "Terminal")
terminals = sapply(terminals, function(t) t$name)

# Build UI.
shinyUI(fluidPage(
  titlePanel("DFW Food & Drink Finder"),
  sidebarLayout(
    sidebarPanel(
      strong("Show me food & drink places in the following categories"),
      checkboxGroupInput("categories",
                         label = "",
                         choices = categories,
                         selected = sample(categories, 3)),
      strong("closest to gate"),
      numericInput("gate", 
                   label = "", 
                   value = sample(1:30, 1)),
      br(),
      strong("in terminal"),
      selectInput("terminal", 
                  label = "", 
                  choices = terminals,
                  selected = sample(terminals, 1)),
      "Powered by", a("Neo4j", 
                      href = "http://www.neo4j.org/",
                      target = "_blank")
    ),
    mainPanel(
      tableOutput("restaurants")
    )
  )
))
```

`server.R`

```r
library(shiny)
library(RNeo4j)

graph = startGraph("http://localhost:7474/db/data/")

query = "
MATCH (p:Place)-[:IN_CATEGORY]->(c:Category),
      (p)-[:AT_GATE]->(g:Gate),
      (g)-[:IN_TERMINAL]->(t:Terminal)
WHERE c.name IN {categories} AND t.name = {terminal}
WITH c, p, g, t, ABS(g.gate - {gate}) AS dist
ORDER BY dist
RETURN p.name AS Name, c.name AS Category, g.gate AS Gate, t.name AS Terminal
"

shinyServer(function(input, output) {
  output$restaurants <- renderTable({
    data = cypher(graph, 
                  query,
                  categories = as.list(input$categories),
                  terminal = input$terminal,
                  gate = input$gate)
    return(data)
  })
}
)
```

In `server.R`, each input is referenced by whatever you named it in `ui.R`. In `ui.R`, each output is referenced by whatever you named it in `server.R`. Again, the Shiny tutorials and articles explain all of this very well. Each time the user changes one of the inputs, the code inside `renderTable()` is re-run to update the output according to the user's new inputs.

To view your app locally in a browser:

```r
runApp("dir")
```

`"dir"` is your app's directory (where you have `server.R` and `ui.R` sitting). You can update both `ui.R` and `server.R` while `runApp()` is working and view your changes by refreshing the page.

To deploy your app and host it at [shinyapps.io](https://www.shinyapps.io/), you'll need to create an account there and follow their directions. You'll also want to install the `shinyapps` package with:

```r
install.packages("devtools")
devtools::install_github("rstudio/shinyapps")
```

To deploy your app:

```r
library(shinyapps)
deployApp("dir")
```

While my app only returns a table, you can easily create a dashboard-like analytics tool for any Neo4j database in Shiny. The [Shiny gallery](http://shiny.rstudio.com/gallery/) has a lot of good examples of highly-interactive charts and maps.