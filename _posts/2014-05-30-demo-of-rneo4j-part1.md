---
layout: post
comments: true
title: Demo of RNeo4j Part 1 - Building a Database.
category: R
---

# Demo of RNeo4j Part 1: Building a Database

I've recently been working on an `R` driver for Neo4j, [RNeo4j](https://github.com/nicolewhite/RNeo4j), and it's gotten to the point where the package mostly works aside from a few known bugs and probably several unknown bugs. To hopefully convince at least one person that this package is useful, I want to demonstrate how you can build and interact with a Neo4j database entirely from your `R` environment.

## Shoutouts

First and foremost, shoutouts to [Hilary Parker](https://twitter.com/hspter) for [showing me how easy it is to build an R package](http://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) and to [Kenny Bastani](https://twitter.com/kennybastani) for very patiently teaching me regular expressions.

## The Vision

I want to build a graph database of Twitter data containing `Users`, `Tweets`, and `Hashtags`. It'll look like this:

<a href="http://i.imgur.com/W8mzgVZ.png" target="_blank"><img src="http://i.imgur.com/W8mzgVZ.png" width="100%" height="100%"></a>

## Get Started

Install `RNeo4j` using `devtools`.

```r
install.packages("devtools")
devtools::install_github("nicolewhite/RNeo4j")
library(RNeo4j)
```

Install `twitteR` and get authenticated.

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

# Save Twitter OAuth credentials for later.
save(twitCred, file = "/home/nicole/twitCred.RData")
```

## Get Tweets

I want to get a bunch of tweets that have the word "neo4j" in them, which is easy with `twitteR`'s `searchTwitter`.

```r
tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 27 May 2014 ~5:00PM CT
more_tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 28 May 2014 ~9:00AM CT
even_more_tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 29 May 2014 ~ 10:00AM CT

neo4j_tweets = c(tweets, more_tweets, even_more_tweets)
```

`searchTwitter` returns a list of `status` objects. The `status` object properties I am interested in are `id`, `text`, `replyToSN`, and `screenName`. These properties can be accessed by `status$property`. For example, the `id` of a tweet can be accessed by `status$id`. 

User mentions, the screen name of who was retweeted, and hashtags (if any) are extracted from the tweet's text with regular expessions, shown below.

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

Establish a connection (make sure Neo4j is running), clear the graph, and add the necessary uniqueness constraints with [`addConstraint`]({{ site.url }}/RNeo4j/docs/add-constraint.html).

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

addConstraint(graph, "Tweet", "id")
addConstraint(graph, "User", "username")
addConstraint(graph, "Hashtag", "hashtag")
```

Now, I need to write a function through which I will pass each `status` object in order to add the tweet to the graph. I can then use `lapply` to apply the function over `neo4j_tweets`.

I only need to use `RNeo4j` functions [`getOrCreateNode`]({{ site.url }}/RNeo4j/docs/get-or-create-node.html) and [`createRel`]({{ site.url }}/RNeo4j/docs/create-rel.html) to build the database. I have to use [`getOrCreateNode`]({{ site.url }}/RNeo4j/docs/get-or-create-node.html) because `Users`, `Hashtags`, and `Tweets` will occur more than once and I don't want to create any duplicates. So, [`getOrCreateNode`]({{ site.url }}/RNeo4j/docs/get-or-create-node.html) either creates the node if it doesn't exist or retrieves it from the graph. The syntax is `getOrCreateNode(graph, label, ...)` where `...` are the node properties in the form `key = value`. It is necessary that uniqueness constraints exist to use this function.

Then, [`createRel`]({{ site.url }}/RNeo4j/docs/create-rel.html) creates a relationship between two nodes with the syntax `createRel(fromNode, type, toNode, ...)`, where `...` are optional relationship properties in the form `key = value`.

The following function takes a `status` object, `x`, as an input and adds it to the graph database.

```r
create_db = function(x) {
  tweet = getOrCreateNode(graph, "Tweet", id = x$id, text = x$text)
  user = getOrCreateNode(graph, "User", username = x$screenName)
  createRel(user, "TWEETED", tweet)

  reply_to_sn = x$replyToSN
  
  if(length(reply_to_sn) > 0) {
    reply_user = getOrCreateNode(graph, "User", username = reply_to_sn)
    createRel(tweet, "IN_REPLY_TO", reply_user)
  }
  
  retweet_sn = getRetweetSN(x$text)
  
  if(!is.null(retweet_sn)) {
    retweet_user = getOrCreateNode(graph, "User", username = retweet_sn)
    createRel(tweet, "RETWEET_OF", retweet_user)
  }
  
  hashtags = getHashtags(x$text)
  
  if(!is.null(hashtags)) {
    hashtag_nodes = lapply(hashtags, function(h) getOrCreateNode(graph, "Hashtag", hashtag = h))
    lapply(hashtag_nodes, function(h) createRel(tweet, "HASHTAG", h))
  }
  
  mentions = getMentions(x$text)
  
  if(!is.null(mentions)) {
      mentioned_users = lapply(mentions, function(m) getOrCreateNode(graph, "User", username = m))
      lapply(mentioned_users, function(u) createRel(tweet, "MENTIONED", u))
  }
} 
```

Now I just need to `lapply` the function `create_db` over the list of `status` objects:

```r
lapply(neo4j_tweets, create_db)
```

And the graph is created! You can download the zip of the database [here](https://dl.dropboxusercontent.com/u/94782892/tweets.zip).

Running `summary` on the `graph` object returns results for the "What is related and how?" query.

```r
summary(graph)

#    This          To    That
# 1 Tweet     HASHTAG Hashtag
# 2  User     TWEETED   Tweet
# 3 Tweet   MENTIONED    User
# 4 Tweet  RETWEET_OF    User
# 5 Tweet IN_REPLY_TO    User
```

And of course, going to the browser is always fun. Here's [Richard Searle](https://twitter.com/rc_searle) in the graph.

<a href="http://i.imgur.com/4h98bp2.png" target="_blank"><img src="http://i.imgur.com/4h98bp2.png" width="100%" height="100%"></a>

With the database created, I can start using `RNeo4j` functions designed to retrieve data from the database. See [Part 2: Plotting and Analysis]({{ site.url }}/r/2014/05/30/demo-of-rneo4j-part2.html).