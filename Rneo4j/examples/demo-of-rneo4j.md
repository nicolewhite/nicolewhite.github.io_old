---
layout: rneo4j
title: Demo of Rneo4j
---

# Demo of Rneo4j

I've recently been working on an `R` driver for Neo4j, [Rneo4j](https://github.com/nicolewhite/Rneo4j), and it's gotten to the point where the package mostly works aside from a few known bugs and probably several unknown bugs. To hopefully convince at least one person that this package is useful, I want to demonstrate how you can build and interact with a Neo4j database entirely from your `R` environment.

## Shoutouts

First and foremost, shoutouts to [Hilary Parker](https://twitter.com/hspter) for [showing me how easy it is to build an R package](http://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) and to [Kenny Bastani](https://twitter.com/kennybastani) for very patiently teaching me regular expressions.

## The Vision

I want to build a database of tweets containing `Users`, `Tweets`, and `Hashtags`. It'll look something like this:

STRUCTURE HERE

I then want to pull data from the database into `R` for analysis and plotting.

## Getting Started

Install `Rneo4j` using `devtools`:

```r
install.packages("devtools")
devtools::install_github("nicolewhite/Rneo4j")
library(Rneo4j)
```

Install `twitteR` and get authenticated:

```r
install.packages("twitteR")
library(twitteR)

reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "http://api.twitter.com/oauth/authorize"

consumerKey <- "5ij43543flskfsdafdsa322"
consumerSecret <- "rwe5432k5jh42j3klh5jkl23"

twitCred <- OAuthFactory$new(consumerKey=consumerKey,
                             consumerSecret=consumerSecret,
                             requestURL=reqURL,
                             accessURL=accessURL,
                             authURL=authURL)

twitCred$handshake()
registerTwitterOAuth(twitCred)
save(twitCred, file = "/home/nicole/twitCred.RData") # Save Twitter OAuth credentials for later.
```

## Get Tweets

I need to get a bunch of tweets that have the word "neo4j" in them, which is easy with `twitteR`'s `searchTwitter`:

```r
tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 27 May 2014 ~5:00PM CT
more_tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 28 May 2014 ~9:00AM CT
even_more_tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 29 May 2014 ~ 10:00AM CT

# Save for later.
save(tweets, more_tweets, even_more_tweets, file = "/home/nicole/tweets.RData")
```

`searchTwitter` returns a list of `status` objects. The `status` object properties we are interested in are `id`, `text`, `replyToSN`, and `screenName`. User mentions, the screen name of who was retweeted, and hashtags (if any) are extracted with regular expessions:

```r
install.packages("stringr")
library(stringr)

getHashtags = function(twit) {
  hashtags = unlist(str_extract_all(twit, perl("(?<=\\s|^)#(.+?)(?=\\b|$)")))
  hashtags = tolower(hashtags)
  
  if(length(hashtags) > 0) {
    return(hashtags)
  } else {
    return(NULL)
  }
}

getRetweetSN = function(twit) {
  retweet = str_extract(twit, perl("(?<=^RT\\s@)(.+?)(?=:)"))
  
  if(!is.na(retweet)) {
    return(retweet)
  } else {
    return(NULL)
  }
}

getMentions = function(twit) {
  mentions = unlist(str_extract_all(twit, perl("(?<!^RT\\s@|^@)(?<=@)(.+?)(?=\\b|$)")))
  
  if(length(mentions) > 0) {
    return(mentions)
  } else{
    return(NULL)
  }
}
```

## Build the Database

Load the tweets that were saved earlier.

```r
load("/home/nicole/tweets.RData")
neo4j_tweets = c(tweets, more_tweets, even_more_tweets)
```

Establish a connection (make sure Neo4j is running), clear the graph, and add the necessary uniqueness constraints with [`addConstraint`]({{ site.url }}/Rneo4j/docs/add-constraint.html).

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

addConstraint(graph, "Tweet", "id")
addConstraint(graph, "User", "username")
addConstraint(graph, "Hashtag", "hashtag")
```

Now, I need to write a function through which I will pass each `status` object in order to add the tweet to the graph. I can then use `lapply` to apply the function over `neo4j_tweets`.

The input to the function `create_db`, `x`, is the `status` object being passed in. A property of the `status` object, such as its text, is accessed through `x$text`.

I only need to use `Rneo4j` functions [`getOrCreateNode`]({{ site.url }}/Rneo4j/docs/get-or-create-node.html) and [`createRel`]({{ site.url }}/Rneo4j/docs/create-rel.html) to build the database. I have to use `getOrCreateNode` because `Users`, `Hashtags`, and `Tweets` will occur more than once and I don't want to create any duplicates. So, `getOrCreateNode` either creates the node if it doesn't exist or retrieves it from the graph. The syntax is `getOrCreateNode(graph, label, ...)` where `...` are the node properties. It is necessary that uniqueness constraints exist to use this function.

Then, `createRel` creates a relationship between two nodes with the syntax `createRel(fromNode, type, toNode, ...)`, where `...` are optional relationship properties. It should be noted that the string supplied for `type` is converted to uppercase and all spaces are replaced with underscores.

```r
create_db = function(x) {
  tweet = getOrCreateNode(graph, "Tweet", id = x$id, text = x$text)
  user = getOrCreateNode(graph, "User", username = x$screenName)
  createRel(user, "tweeted", tweet)

  reply_to_sn = x$replyToSN
  
  if(length(reply_to_sn) > 0) {
    reply_user = getOrCreateNode(graph, "User", username = reply_to_sn)
    createRel(tweet, "in reply to", reply_user)
  }
  
  retweet_sn = getRetweetSN(x$text)
  
  if(!is.null(retweet_sn)) {
    retweet_user = getOrCreateNode(graph, "User", username = retweet_sn)
    createRel(tweet, "retweet of", retweet_user)
  }
  
  hashtags = getHashtags(x$text)
  
  if(!is.null(hashtags)) {
    tags = lapply(hashtags, function(h) getOrCreateNode(graph, "Hashtag", hashtag = h))
    lapply(tags, function(t) createRel(tweet, "hashtag", t))
  }
  
  mentions = getMentions(x$text)
  
  if(!is.null(mentions)) {
      mentioned_users = lapply(mentions, function(m) getOrCreateNode(graph, "User", username = m))
      lapply(mentioned_users, function(u) createRel(tweet, "mentioned", u))
  }
} 
```

Now I just need to `lapply` the function `create_db` over the list of `status` objects:

```r
lapply(neo4j_tweets, create_db)
```

And the graph is created! You can download the zip of the database [here](** * UPDATE THIS ***).

Running `summary` on the `graph` object returns results for the "What is related and how?" query:

```r
summary(graph)

#    This          To    That
# 1 Tweet     HASHTAG Hashtag
# 2  User     TWEETED   Tweet
# 3 Tweet   MENTIONED    User
# 4 Tweet  RETWEET_OF    User
# 5 Tweet IN_REPLY_TO    User
```

And of course, going to the browser is always fun. Here's [Richard Searle](https://twitter.com/rc_searle) in the graph:

![richard](update this)

View [full resolution](update this).

## Do Some Analysis

### Hashtag Co-Occurrence with #Neo4j

The most powerful function in `Rneo4j`, [`cypher`]({{ site.url }}/Rneo4j/docs/cypher.html), allows you to retrieve Cypher query results as an `R` data frame. The following query gets the 10 hashtags that co-occur with #neo4j most frequently and their counts into a data frame called `hashtag_count`.

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

If you wanted to plot these in a bar chart, for example, you could do so easily with `ggplot2`:

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

PIC OF CHART

### Word Cloud

I decided it would be fun to create a word cloud of all the tweets' text using the `wordcloud`, `tm`, and `RColorBrewer` packages.

First, install and load the necessary packages:

```r
install.packages("wordcloud")
install.packages("tm")
install.packages("RColorBrewer")

library(wordcloud)
library(tm)
library(RColorBrewer)
```

I need to get all of the `Tweet` nodes from the graph into a list of `node` objects. This can be done with `Rneo4j`'s [`getLabeledNodes`]({{ site.url }}/Rneo4j/docs/get-labeled-nodes.html) function, which gets all nodes with the specified label:

```r
tweets = getLabeledNodes(graph, "Tweet")
```

Each `node` object's properties can be accessed by `node$property`. For example, the text of the first `node` object in `tweets` is accessed through:

```r
tweets[[1]]$text

# "The beauty of Tom Sawyer Perspectives is that it can not only pull data from the Neo4j database, http://t.co/FA46LO5U6k #DataViz"
```

Use `sapply` to extract the `text` property from each `node` object in `tweets`:

```r
tweet_text = sapply(tweets, function(t) t$text)
```

`tweet_text` is a character vector of all the tweets' text. Now I switch over to the `tm` and `wordcloud` packages to remove stopwords, punctuation, etc. and to create the word cloud. Most of this code is shamelessly copied from the documentation for the `wordcloud` function.

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
          min.freq = 4, 
          max.words = 150,
          random.order = F,
          colors = pal)
```

PIC HERE