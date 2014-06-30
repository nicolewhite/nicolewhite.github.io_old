---
title: Create a Shiny App Powered by a Neo4j Database Hosted on GrapheneDB.
layout: post
comments: true
category: R
---

# Create a Shiny App Powered by a Neo4j Database Hosted on GrapheneDB.

[Shiny](http://shiny.rstudio.com/) is my new favorite thing from RStudio. It's a web framework for R, which is nice for someone like me with little web development experience. The tutorial and gallery pages are a good place to start.

At its most basic, a Shiny app consists of a `ui.R` file and a `server.R` file in the same directory, which was all that I needed to create [this app](https://nicolewhite.shinyapps.io/dfw-app/). You can use any R package that is on CRAN or GitHub in Shiny, so I am able to use RNeo4j to connect to a Neo4j database within my app.

I have a small database of Dallas Fort-Worth Airport restaurants stored in a sandbox instance on [GrapheneDB](http://www.graphenedb.com/). It has the following structure:

```
   This          To     That
1  Gate IN_TERMINAL Terminal
2 Place IN_CATEGORY Category
3 Place     AT_GATE     Gate
```

For example, here is a visualization of terminal A:

<a href="http://i.imgur.com/U9SPDyM.png" target="_blank"><img src="http://i.imgur.com/U9SPDyM.png" width="100%" height="100%"></a>

For my app, I simply wanted to be able to select an arbitrary number of restaurant categories in a certain terminal and order the results by absolute distance from a given gate number. This is really easy to do with the Shiny widgets, whose selections I pass as parameters to a Cypher query.

Before developing, you'll need to install the `shiny` package with:

```r
install.packages("shiny")
library(shiny)
```

And if you eventually want to deploy your app and host it on [shinyapps.io](https://www.shinyapps.io/), you'll want to install the `shinyapps` package with:

```r
install.packages("devtools")
devtools::install_github("rstudio/shinyapps")
library(shinyapps)
```

Below are my `ui.R` and `server.R` files, which are pretty easy to follow once you've read through the [Shiny tutorial](http://shiny.rstudio.com/tutorial/).

`ui.R`

```r
shinyUI(fluidPage(
  titlePanel("DFW Food & Drink Finder"),
  sidebarLayout(
    sidebarPanel(
      strong("Show me food & drink places in the following categories"),
      checkboxGroupInput("categories",
                         label = "",
                         choices = list("American Cuisine" = "American Cuisine", 
                                        "Asian" = "Asian", 
                                        "Bar" = "Bar", 
                                        "Barbecue" = "Barbecue", 
                                        "Coffee" = "Coffee", 
                                        "Desserts & Snacks" = "Desserts & Snacks", 
                                        "Fast Food" = "Fast Food", 
                                        "Grand Hyatt Dining" = "Grand Hyatt Dining", 
                                        "Italian/Pizza" = "Italian/Pizza",
                                        "Mexican/Southwest" = "Mexican/Southwest",
                                        "Sandwich/Deli" = "Sandwich/Deli",
                                        "Seafood" = "Seafood"),
                         selected = "Coffee"),
      strong("closest to gate"),
      numericInput("gate", 
                   label = "", 
                   value = 1),
      br(),
      strong("in terminal"),
      selectInput("terminal", 
                  label = "", 
                  choices = list("A" = "A", 
                                 "B" = "B",
                                 "C" = "C",
                                 "D" = "D",
                                 "E" = "E"),
                  selected = "A"),
      "Powered by", a("Neo4j", 
                      href = "http://www.neo4j.org/",
                      target = "_blank"), 
      "and", a("GrapheneDB",
               href = "http://www.graphenedb.com/",
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
library(RNeo4j)

graph = startGraph("http://dfw.sb02.stations.graphenedb.com:24789/db/data/",
                   username = "dfw",
                   password = "TOP_SECRET!!!")

query1 = "MATCH (c:Category)<-[:IN_CATEGORY]-(p:Place)-[:AT_GATE]->(g:Gate)-[:IN_TERMINAL]->(t:Terminal {name:{terminal}})"
          
query2 = "WITH p, g, t, g.gate - {gate} AS dist
          ORDER BY ABS(dist)
          RETURN DISTINCT p.name AS Name, g.gate AS Gate, t.name AS Terminal"

shinyServer(function(input, output) {
  output$restaurants <- renderTable({
    if(length(input$categories) > 1) {
      query = paste(query1, "WHERE c.name IN {categories}", query2)
    } else if(length(input$categories == 1)) {
      query = paste(query1, "WHERE c.name = {categories}", query2)
    } else {
      query = paste(query1, query2)
    }
    data = cypher(graph, 
                  query,
                  categories = input$categories,
                  terminal = input$terminal,
                  gate = input$gate)
    return(data)
  })
}
)
```

The URL, username, and password for the database are under the Connection tab in your GrapheneDB dashboard. In `server.R`, each input is referenced by whatever you named it in `ui.R`. In `ui.R`, each output is referenced by whatever you named it in `server.R`. Again, the Shiny tutorials and articles explain all of this very well. Both [startGraph](http://nicolewhite.github.io/RNeo4j/docs/start-graph.html) and [cypher](http://nicolewhite.github.io/RNeo4j/docs/cypher.html) are functions in my RNeo4j package.

Each time the user changes one of the inputs, the code inside `renderTable()` is re-run to update the output with the user's new inputs.

My `if-else` logic in `server.R` is handling the different data types that can be returned by `input$categories`:

```r
    if(length(input$categories) > 1) {
      query = paste(query1, "WHERE c.name IN {categories}", query2)
    } else if(length(input$categories == 1)) {
      query = paste(query1, "WHERE c.name = {categories}", query2)
    } else {
      query = paste(query1, query2)
    }
```

If the user selects more than one category, `input$categories` is a character vector and I want to check if the category name is in that vector; else, if the user selects only a single category, `input$categories` is a string and I want to check if the category name is equal to that string; else, if the user doesn't select any categories, `input$categories` is empty and I omit the conditional from the query altogether so that all categories are returned.

To view your app locally in a browser, execute `runApp("dir")` where `"dir"` is your app's directory. You can update both `ui.R` and `server.R` while `runApp()` is working and view your changes by refreshing the page.

To deploy your app and host it at [shinyapps.io](https://www.shinyapps.io/), you'll need to create an account there and follow their directions. You eventually run `deployApp("dir")` to deploy your app. This is free at the moment, though it looks like they will be adding [tiered pricing](https://www.shinyapps.io/pricing) in the near future (including a free tier for minimal apps).

While mine only returns a table, you can easily create a dashboard-like analytics tool for any Neo4j database in Shiny. The [Shiny gallery](http://shiny.rstudio.com/gallery/) has a lot of good examples of highly-interactive charts and maps.
