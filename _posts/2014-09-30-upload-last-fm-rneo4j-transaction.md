---
layout: post
comments: true
title: Upload Your Last.fm Data to Neo4j with RNeo4j and the Transactional Endpoint.
category: R
---

# Upload Your Last.fm Data to Neo4j with RNeo4j and the Transactional Endpoint.

Recently I've had several people ask how they can use RNeo4j to import data that they have stored either in a CSV file or R data object. The [example I have in the documentation](http://nicolewhite.github.io/RNeo4j/docs/transactions.html) uses a very small data frame, but more realistically you'll have a data frame with several thousand rows. In that case, you'll want to upload the data in blocks through the transactional endpoint, which I demo here. 

It should be noted that this method will never be faster than [LOAD CSV](http://docs.neo4j.org/chunked/stable/query-load-csv.html) or the lightning-fast [batch importer](https://github.com/jexp/batch-import). But LOAD CSV has its issues, and the batch importer requires quite a lot of data pre-processing before it can be used. For modest datasets (< 1,000,000 rows), I find uploading through RNeo4j the quickest way for me to get up and running.

## Data Collection

[Last.fm](http://www.last.fm/) is a service that keeps track of your music listening history. Each track you play and that Last.fm records is called a "scrobble." I wrote an R script that calls the Last.fm API to collect all of a user's scrobble history and write it to a CSV file. I did this for [myself](http://www.last.fm/user/nmwhite0131) along with my friends [Julian](http://www.last.fm/user/smooligans) and [Aaron](http://www.last.fm/user/aaronsrun). If you want to do this yourself, you'll need to [get your own API key from Last.fm](http://www.last.fm/api/account/create). Just overwrite `API_KEY` with your API key and pass your Last.fm username to `get_scrobbles()`. For the following, I use Last.fm's [User.getRecentTracks](http://www.last.fm/api/show/user.getRecentTracks) endpoint to iterate through a user's entire scrobble history.

```r
# Don't run this while currently scrobbling. 
# The now-playing track will not have a timestamp, which'll mess everything up.
options(stringsAsFactors = F)

library(RCurl)
library(jsonlite)
library(dplyr)

# REST API things.
REST_URL = "http://ws.audioscrobbler.com/2.0/"
API_KEY = Sys.getenv('LASTFM_KEY')

# Function for getting scrobble history and writing to csv.
get_scrobbles <- function(user) {
  # Convert JSON to data frame.
  clean <- function(json) {
    data = fromJSON(json)
    data = data$recenttracks$track
    
    data = data.frame(user = user, 
                      track = data$name, 
                      artist = data$artist$'#text', 
                      date = data$date$'#text', 
                      timestamp = data$date$uts)
    return(data)
  }
  
  # Start with the timestamp of the current time.
  max_unix = as.numeric(strftime(as.POSIXct(Sys.time()), '%s'))
  
  data = data.frame()
  
  # Work backward through user's scrobble history.
  repeat{
    json = getForm(REST_URL,
                   method = "user.getrecenttracks",
                   user = user,
                   api_key = API_KEY,
                   limit = 200,
                   to = max_unix,
                   format = "json")
    
    new_data = try(clean(json), silent = T)
    
    # There will be an error in clean() if no additional data is returned.
    if(class(new_data) == "try-error") {
      print("All scrobbles found.")
      break
    }
    
    # Append new data.
    data = rbind(data, new_data)
    print(paste(nrow(new_data), "scrobbles added for a total of", nrow(data), "scrobbles."))
    
    # Update max timestamp to get next 200 scrobbles.
    max_unix = min(new_data$timestamp)
  }
  
  # Reorder scrobbles by timestamp ascending.
  data = arrange(data, timestamp)
  
  # Write to csv.
  write.csv(data, file = paste(Sys.Date(), user, 'scrobbles.csv', sep = "_"), row.names = F)
}

# Get scrobble history for me and my friends.
get_scrobbles("nmwhite0131")
get_scrobbles("smooligans")
get_scrobbles("aaronsrun")
```

## Data Model

Before I begin uploading, I need to come up with a data model. I've decided that I want to keep the scrobbles in a linked list so I can ask cool questions about the order in which I and my friends listen to music.

<a href="https://dl.dropboxusercontent.com/u/94782892/lastfm.svg" target="_blank"><img src="https://dl.dropboxusercontent.com/u/94782892/lastfm.svg" width="100%" height="100%"></a>

## Initial Data Upload

First I'll get all the CSV files into a data frame:

```r
csvs = list.files(pattern = "*.csv")

data = data.frame()

for(i in 1:length(csvs)) {
  new_data = read.csv(csvs[i])
  data = rbind(data, new_data)
}
```

The following summarizes the contents of this data frame:

```r
> nrow(data)
[1] 40214

> names(data)
[1] "user"      "track"     "artist"    "date"      "timestamp"
```

Now I'll add some uniqueness constraints and define the Cypher query that will create the graph:

```r
# Connect to graph db and add uniqueness constraints.
library(RNeo4j)

graph = startGraph("http://localhost:7474/db/data/")

addConstraint(graph, "User", "username")
addConstraint(graph, "Artist", "name")

# Define import query.
query = "
CREATE (scrobble:Scrobble {date:{date},timestamp:TOINT({timestamp})})

MERGE (user:User {username:{user}})
MERGE (artist:Artist {name:{artist}})
MERGE (track:Track {name:{track},artist:{artist}})

MERGE (user)-[:SCROBBLED]->(scrobble)
MERGE (scrobble)-[:PLAYED]->(track)
MERGE (track)-[:SUNG_BY]->(artist)

WITH user, scrobble
MATCH (user)-[:SCROBBLED]->(prev:Scrobble)
WHERE prev.timestamp < scrobble.timestamp AND NOT((prev)-[:NEXT]->(:Scrobble))
MERGE (prev)-[:NEXT]->(scrobble)
"
```

The latter portion of the import query is managing the linked list. For every new scrobble (or row in the data frame), the query finds the user's most previous scrobble and appends the current scrobble to the end of the linked list.

Finally, I'll iterate through my data frame in blocks of 1,000 rows and use the [transactional endpoint](/RNeo4j/docs/transactions.html) to upload my data:

```r
# Start initial transaction.
tx = newTransaction(graph)

for (i in 1:nrow(data)) {
  # Upload in blocks of 1000.
  if(i %% 1000 == 0) {
    # Commit current transaction.
    commit(tx)
    print(paste("Batch", i / 1000, "committed."))
    # Open new transaction.
    tx = newTransaction(graph)
  }
  
  # Append paramaterized Cypher query to transaction.
  appendCypher(tx,
               query,
               date = data$date[i],
               timestamp = data$timestamp[i],
               user = data$user[i],
               artist = data$artist[i],
               track = data$track[i])
}

# Commit last transaction.
commit(tx)
print("Last batch committed.")
print("All done!")
```

After starting the script above, I warmed up some Bagel Bites and made myself a drink. By the time I got back to my computer, I had a graph database waiting for me! I can confirm the data was uploaded by testing a query:

```r
# Get my 5 most recent scrobbles.
query = "
MATCH (:User {username:'nmwhite0131'})-[:SCROBBLED]->(last:Scrobble),
      recent = (:Scrobble)-[:NEXT*4]->(last)
WHERE NOT ((last)-[:NEXT]->(:Scrobble))
WITH NODES(recent) AS scrobbles
UNWIND scrobbles AS s
MATCH (s)-[:PLAYED]->(t:Track)-[:SUNG_BY]->(a:Artist)
RETURN s.date, t.name, a.name
"
```

```r
> cypher(graph, query)
              s.date       t.name a.name
1 24 Sep 2014, 21:57         Easy Saycet
2 24 Sep 2014, 22:01     BruyÃ¨re Saycet
3 24 Sep 2014, 22:05         Opal Saycet
4 24 Sep 2014, 22:08    Her Movie Saycet
5 24 Sep 2014, 22:12 We Walk Fast Saycet
```

## Update the Database

After I created this database, I decided I wanted to add genre information for the artists. I found the [Artist.getTopTags](http://www.last.fm/api/show/artist.getTopTags) endpoint, which returns a list of top user-applied tags for the given artist. For the tag with the highest count, I'll update the artist nodes currently in the database with the following:

<a href="https://dl.dropboxusercontent.com/u/94782892/lastfm2.png" target="_blank"><img src="https://dl.dropboxusercontent.com/u/94782892/lastfm2.png" width="100%" height="100%"></a>

This update will be pretty simple. I need to:

* Get a list of distinct artist names currently in my database.
* Pass each of these artist names to the Artist.getTopTags endpoint.
* Create an `(:Artist)-[:MEMBER_OF]->(:Genre)` relationship for the top tag (the tag with the highest count).

To get a list of artist names, I'll use [getLabeledNodes](/RNeo4j/docs/get-labeled-nodes.html) to get all artist nodes and then `sapply` over that list to extract the `name` property:

```r
# Get list of artist names.
artists = getLabeledNodes(graph, "Artist")
artists = sapply(artists, function(a) a$name)
```

There are only 1,677 artists in the database:

```r
> length(artists)
[1] 1677
```

Again I'll use the transactional endpoint to upload this data:

```r
# Define import query.
query = "
MATCH (artist:Artist {name:{artist}})
MERGE (genre:Genre {name:UPPER({genre})})
MERGE (artist)-[:MEMBER_OF]->(genre)
"

# Open initial transaction.
tx = newTransaction(graph)

for(i in 1:length(artists)) {
  # Upload in blocks of 100.
  if(i %% 100 == 0) {
    # Commit current transaction.
    commit(tx)
    # Open new transaction.
    tx = newTransaction(graph)
  }
  json = getForm(REST_URL,
                 method = "artist.gettoptags",
                 artist = artists[i],
                 api_key = API_KEY,
                 format = "json")
  
  genre = fromJSON(json)$toptags$tag$name[1]
  
  if(!is.null(genre)) {
    appendCypher(tx, query, artist = artists[i], genre = genre)
  }
}

# Commit last transaction.
commit(tx)
```

And now I have a database of the following structure:

```r
> summary(graph)
      This        To     That
1 Scrobble    PLAYED    Track
2 Scrobble      NEXT Scrobble
3     User SCROBBLED Scrobble
4   Artist MEMBER_OF    Genre
5    Track   SUNG_BY   Artist
```

Here's a snapshot from the browser showing an instance where me and my friend Julian listened to two tracks in the same order:

<a href="http://i.imgur.com/PbnrLDd.png" target="_blank"><img src="http://i.imgur.com/PbnrLDd.png" width="100%" height="100%"></a>

You can view all the code for this project [here](https://github.com/nicolewhite/last_fm_graph). In my next series of posts, I'll explore this dataset within R. This will include some plotting and predictive modeling.