---
layout: default
title: Demo of Rneo4j Part 2 - Plotting and Analysis
---

# Demo of Rneo4j Part 2: Plotting and Analysis

[Part 1: Building a Database]({{ site.url }}/2014/05/30/demo-of-rneo4j-part1.html)

In Part 1, I built a database using `Rneo4j` and `twitteR`. Now I can use `Rneo4j` to retreive data from the database for plotting and analysis using a few of `R`'s many available packages.

## Hashtag Co-Occurrence with #Neo4j

My favorite function in `Rneo4j`, [`cypher`]({{ site.url }}/Rneo4j/docs/cypher.html), allows you to retrieve Cypher query results as an `R` data frame. The following query gets the 10 hashtags that co-occur with #neo4j most frequently and their counts into a data frame called `hashtag_count`.

```r
query = "MATCH (h:Hashtag)<-[:HASHTAG]-(:Tweet)-[:HASHTAG]->(:Hashtag {hashtag:{hashtag}}) 
         WHERE h.hashtag <> {hashtag}
         RETURN h.hashtag AS hashtag, COUNT(*) AS count
         ORDER BY count DESC
         LIMIT 10"

hashtag_count = cypher(graph, query, hashtag = "#neo4j")

hashtag_count

#           hashtag count
# 1         #spring    10
# 2      #graphunit     9
# 3         #vaadin     8
# 4         #munich     7
# 5  #graphdatabase     7
# 6       #graphpub     6
# 7        #graphdb     6
# 8   #graphhackday     6
# 9     #graphaware     6
# 10         #graph     5
```

With the results in a data frame, I can easily create charts using `ggplot2`. If I wanted to plot the information in `hashtag_count` in a bar chart, for example, I can do so with the following.

```r
install.packages("ggplot2")
library(ggplot2)

ggplot(hashtag_count, aes(x = reorder(hashtag, count), y = count)) + 
  geom_bar(stat = "identity", fill = "darkblue") +
  coord_flip() +
  labs(x = "Hashtag", 
       y = "Count", 
       title = "Count of Hashtag Co-Occurrence with #Neo4j") +
  theme(axis.text = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 14, color = "black"),
        plot.title = element_text(size = 16, color = "black"))
```

![hashtags](http://i.imgur.com/kkjzKsn.png)

View [full resolution](http://i.imgur.com/kkjzKsn.png).

### Word Cloud

I decided it would be fun to create a word cloud of all the tweets' text using the `wordcloud`, `tm`, and `RColorBrewer` packages.

First, install and load the necessary packages.

```r
install.packages("wordcloud")
install.packages("tm")
install.packages("RColorBrewer")

library(wordcloud)
library(tm)
library(RColorBrewer)
```

Next I need to get all of the `Tweet` nodes from the graph into a list of `node` objects. This can be done with `Rneo4j`'s [`getLabeledNodes`]({{ site.url }}/Rneo4j/docs/get-labeled-nodes.html) function, which gets all nodes with the specified label.

```r
tweet_nodes = getLabeledNodes(graph, "Tweet")
```

Each `node` object's properties can be accessed by `node$property`. For example, the text of the first `node` object in `tweet_nodes` is accessed through the following.

```r
tweet_nodes[[1]]$text

# "The beauty of Tom Sawyer Perspectives is that it can not only pull data from the Neo4j database, http://t.co/FA46LO5U6k #DataViz"
```

Use `sapply` to extract the `text` property from each `node` object in `tweet_nodes`.

```r
tweet_text = sapply(tweet_nodes, function(t) t$text)
```

`tweet_text` is a character vector of all the tweets' text. Now I switch over to the `tm` package to remove stopwords, punctuation, etc., and then to the `RColorBrewer` and `wordcloud` packages to create the word cloud. Most of this code is shamelessly copied from the documentation for the `wordcloud` function.

```r
# Remove links.
tweet_text = sapply(tweet_text, function(t) str_replace_all(t, perl("http.+?(?=(\\s|$))"), ""))

# Remove stopwords, punctuation, etc.
tweet_corpus = Corpus(VectorSource(tweet_text))
tweet_corpus = tm_map(tweet_corpus, removePunctuation)
tweet_corpus = tm_map(tweet_corpus, tolower)
tweet_corpus = tm_map(tweet_corpus, function(x) removeWords(x, c(stopwords("english"), "neo4j")))

# Get term-document matrix and then a term-frequency data frame.
tdm = TermDocumentMatrix(tweet_corpus)
m = as.matrix(tdm)
v = sort(rowSums(m),decreasing=TRUE)
d = data.frame(word = names(v),freq=v)

# Create the word cloud.
pal = brewer.pal(9,"Dark2")
wordcloud(words = d$word, 
          freq = d$freq, 
          scale = c(8,.3), 
          random.order = F,
          colors = pal)
```

![wordcloud](http://i.imgur.com/OF1ZeRQ.png)

View [full resolution](http://i.imgur.com/OF1ZeRQ.png).
