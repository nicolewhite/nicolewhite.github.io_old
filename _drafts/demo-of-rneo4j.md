---
layout: default
title: Demo of Rneo4j
---

# Demo of Rneo4j

I've recently been working on an `R` driver for Neo4j, `Rneo4j`, and it's gotten to the point where the package mostly works aside from a few known bugs and probably several unknown bugs.

To hopefully convince at least one person that this package is useful, I want to demonstrate how you can build and interact with a Neo4j database entirely from your `R` environment.

## Shoutouts

First and foremost, shoutouts to [Hilary Parker](https://twitter.com/hspter) for [showing me how easy it is to build an `R` package](http://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) and to [Kenny Bastani](https://twitter.com/kennybastani) for very patiently teaching me regular expressions.

## The Vision

I want to build a database of tweets containing Users, Tweets, and Hashtags. It'll look something like this:

PIC

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

I want to get a bunch of tweets that have the word "neo4j" in them, which is easy with `searchTwitter`:

```r
tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 27 May 2014 ~5:00PM CT
more_tweets = searchTwitter("neo4j", n = 100, lang = "en") # Run on 28 May 2014 ~9:00AM CT

# Save for later.
save(tweets, file = "/home/nicole/tweets.RData")
save(more_tweets, file = "/home/nicole/more_tweets.RData")
```

`searchTwitter` returns a list of `status` objects. The `status` object properties we are interested in are `id`, `text`, `replyToSN`, and `screenName`. User mentions, the screen name of who was retweeted, and hashtags (if any) are extracted with regular expessions:

```r
install.packages("stringr")
library(stringr)

getHashtags = function(twit) {
  hashtags = unlist(str_extract_all(twit, perl("#(.+?)(?=\\b|$)")))
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
  mentions = unlist(str_extract_all(twit, perl("(?<!^RT\\s)@(.+?)(?=\\b|$)")))
  mentions = lapply(mentions, function(m) str_replace_all(m, "@", ""))
  
  if(length(mentions) > 0) {
    return(mentions)
  } else{
    return(NULL)
  }
}
```

## Build the Database

Load the tweets that we saved earlier.

```r
load("/home/nicole/tweets.RData")
load("/home/nicole/more_tweets.RData")
neo4j_tweets = c(tweets, more_tweets)
```

Establish a connection (make sure Neo4j is running), clear the graph, and add the necessary constraints.

```r
graph = startGraph("http://localhost:7474/db/data/")
clear(graph)

addConstraint(graph, "Tweet", "id")
addConstraint(graph, "User", "username")
addConstraint(graph, "Hashtag", "hashtag")
```

Now, we need to write a function that we will pass each `status` object through in order to add the tweet to the graph. We can then use `lapply` to apply the function to the list of `status` objects, `neo4j_tweets`.

The input to the function `create_db`, `x`, is the `status` object being passed in. A property of the status object, such as its text, is accessed through `x$text`.

I only need to use `Rneo4j` functions `getOrCreateNode` and `createRel` to build the database. I have to use `getOrCreateNode` because Users, Hashtags, and Tweets will occur more than once and we don't want to create any duplicates. So, `getOrCreateNode` either creates the node if it doesn't exist or retrieves it from the graph. It is necessary that uniqueness constraints exist to use this function.

Then, `createRel` creates a relationship between two nodes with the syntax `createRel(fromNode, type, toNode, ...)`, where `...` are optional relationship properties. It should be noted that the string supplied for `type` is converted to uppercase and all spaces replaced with underscores.

```r
create_db = function(x) {
  tweet = getOrCreateNode(graph, "Tweet", id = x$id, text = x$text)
  user = getOrCreateNode(graph, "User", username = x$screenName)
  createRel(user, "tweeted", tweet)

  reply_to_sn = x$replyToSN
  
  # An empty sn returns character(0)
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

Now we just need to `lapply` the function `create_db` over the list of `status` objects:

```r
lapply(neo4j_tweets, create_db)
```

And the graph is created! Running `summary` on the `graph` object returns results for the "What is related and how?" query:

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

```
MATCH p = (:User {username:'rc_searle'})-[:TWEETED]->(t:Tweet)-->() RETURN p
```

PICTURE HERE

## Do Some Analysis in R

Now that the database exists, we can do some analysis. I decided it would be fun to create a word cloud of all tweets' text using the `wordcloud` and `tm` packages.

First, install and load the necessary packages:

```r
install.packages("wordcloud")
install.packages("tm")

library(wordcloud)
library(tm)
```

We need to get all of the `Tweet` nodes from the graph into a list of `node` objects. This can be done with `Rneo4j`'s `getLabeledNodes` function, which gets all nodes with the specified label:

```r
tweets = getLabeledNodes(graph, "Tweet")
```

Each `node` object's properties can be accessed by `node$property`. For example, the text of the first `node` object in `tweets` is accessed through:

```r
tweets[[1]]$text

# "The beauty of Tom Sawyer Perspectives is that it can not only pull data from the Neo4j database, http://t.co/FA46LO5U6k #DataViz"
```

We can use `sapply` to extract the `text` property from each `node` object in `tweets`:

```r
tweet_text = sapply(tweets, function(t) t$text)
```

We now have a character vector of all the tweets' text. At this point, we'll switch over to the `tm` and `wordcloud` packages to remove stopwords, punctuation, etc. and to create the word cloud. Most of this code is shamelessly stolen from [here](http://onertipaday.blogspot.com/2011/07/word-cloud-in-r.html).

```r
# Remove links.
tweet_text = sapply(tweet_text, function(t) str_replace_all(t, perl("http.+?(?=(\\s|$))"), ""))

# Remove stopwords, punctuation, etc.
tweet_corpus = Corpus(VectorSource(tweet_text))
tweet_corpus = tm_map(tweet_corpus, removePunctuation)
tweet_corpus = tm_map(tweet_corpus, tolower)
tweet_corpus = tm_map(tweet_corpus, function(x) removeWords(x, stopwords("english")))
tweet_corpus = tm_map(tweet_corpus, function(x) removeWords(x, "neo4j"))

# Get term-document matrix and then a term-frequency data frame.
tdm = TermDocumentMatrix(tweet_corpus)
m = as.matrix(tdm)
v = sort(rowSums(m),decreasing=TRUE)
d = data.frame(word = names(v),freq=v)

# Create the word cloud.
wordcloud(d$word, d$freq, min.freq = 2)
```

![wordcloud](http://i.imgur.com/ElAFvYV.png)