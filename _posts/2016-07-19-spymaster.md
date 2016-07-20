---
comments: yes
layout: post
title: "Codenames: Playing Spymaster with R."
---



# Codenames: Playing Spymaster with R.

I've been playing a game called [Codenames](https://boardgamegeek.com/boardgame/178900/codenames) with my friends recently. There is a grid of 25 words and two teams. Some of these words belong to the red team and some of them belong to the blue team. Each team has a spymaster; these players know which words belong to which team and they are tasked with giving one-word clues that are associated with multiple words belonging to their team. There is also an assassin word. If your team guesses the assassin word, your team automatically loses the game. It's important for the spymasters to give clues related to their words but that don't accidentally steer their teammates toward guessing the assassin word, and, to a lesser extent, clues that don't accidentally steer their teammates toward guessing the other team's words.

A board might look like this:

<table>
<tr><td bgcolor="#FBEEBB">WATER</td><td bgcolor="#FBEEBB">PLATE</td><td bgcolor="#FBEEBB">SHOP</td><td bgcolor="#FBEEBB">BALL</td><td bgcolor="#FBEEBB">OIL</td></tr>
<tr><td bgcolor="#FBEEBB">ROBIN</td><td bgcolor="#FBEEBB">HOSPITAL</td><td bgcolor="#FBEEBB">CONTRACT</td><td bgcolor="#FBEEBB">EAT</td><td bgcolor="#FBEEBB">WAR</td></tr>
<tr><td bgcolor="#FBEEBB">BRIDGE</td><td bgcolor="#FBEEBB">SATURN</td><td bgcolor="#FBEEBB">MARCH</td><td bgcolor="#FBEEBB">FIRE</td><td bgcolor="#FBEEBB">LINE</td></tr>
<tr><td bgcolor="#FBEEBB">STREAM</td><td bgcolor="#FBEEBB">NEEDLE</td><td bgcolor="#FBEEBB">HAWK</td><td bgcolor="#FBEEBB">GASOLINE</td><td bgcolor="#FBEEBB">HEAD</td></tr>
<tr><td bgcolor="#FBEEBB">ENGINE</td><td bgcolor="#FBEEBB">SPOON</td><td bgcolor="#FBEEBB">BATTERY</td><td bgcolor="#FBEEBB">MOUSE</td><td bgcolor="#FBEEBB">LITTER</td></tr>
</table>

As I mentioned, only the spymasters know which words belong to which team. Their view would look like this:

<table>
<tr><td bgcolor="ff6a6a">WATER</td><td bgcolor="ff6a6a">PLATE</td><td bgcolor="#FBEEBB">SHOP</td><td bgcolor="#FBEEBB">BALL</td><td bgcolor="ff6a6a">OIL</td></tr>
<tr><td bgcolor="lightblue">ROBIN</td><td bgcolor="lightblue">HOSPITAL</td><td bgcolor="#FBEEBB">CONTRACT</td><td bgcolor="ff6a6a">EAT</td><td bgcolor="lightblue">WAR</td></tr>
<tr><td bgcolor="lightblue">BRIDGE</td><td bgcolor="#FBEEBB">SATURN</td><td bgcolor="lightblue">MARCH</td><td bgcolor="darkgrey">FIRE</td><td bgcolor="#FBEEBB">LINE</td></tr>
<tr><td bgcolor="ff6a6a">STREAM</td><td bgcolor="lightblue">NEEDLE</td><td bgcolor="lightblue">HAWK</td><td bgcolor="ff6a6a">GASOLINE</td><td bgcolor="#FBEEBB">HEAD</td></tr>
<tr><td bgcolor="ff6a6a">ENGINE</td><td bgcolor="ff6a6a">SPOON</td><td bgcolor="lightblue">BATTERY</td><td bgcolor="lightblue">MOUSE</td><td bgcolor="#FBEEBB">LITTER</td></tr>
</table>

I want to build a program that can play spymaster; that is, a program that can take the information given in the above board and figure out the best clues to give to its teammates.

My program is going to play spymaster for the red team. Here is my overall strategy:

* Treat each codename as a document
* Determine similarities between each document
* Determine the most natural clustering of these documents with hierarchical clustering
* Find the best one-word clue for each cluster

For simplicity, I'll only consider the red team's words and the assassin word as a minimum viable strategy.


```r
board = c("water", "plate", "shop", "ball", "oil",
          "robin", "hospital", "contract", "eat", "war",
          "bridge", "saturn", "march", "fire", "line",
          "stream", "needle", "hawk", "gasoline", "head",
          "engine", "spoon", "battery", "mouse", "litter")


red_codenames = c("water", "plate", "oil", "eat", "stream", "gasoline", "engine", "spoon")

assassin = "fire"
```

## Treat each codename as a document

I decided the document to represent each codename should be the word's Wikipedia article. The text of each word's article was saved in `data/{word}.txt`.


```r
# Thank you to /u/guepier for updates to this code.
# https://www.reddit.com/r/rstats/comments/4tnmv3/codenames_playing_spymaster_with_r/d5jd69d
read_definition = function (codename) {
    filename = paste0("data/", codename, ".txt")
    readChar(filename, file.info(filename)$size)
}

spymaster = data.frame(codename = red_codenames,
                       text = vapply(red_codenames, read_definition, character(1)))
```

`spymaster` is a data.frame with two columns, the codename and its article text.


```r
apply(spymaster, 2, function(x) {substr(x, 1, 50)})
```

```
##          codename   text                                                
## water    "water"    "Water (chemical formula: H2O) is a transparent flu"
## plate    "plate"    "A roundel is a circular charge in heraldry. Rounde"
## oil      "oil"      "An oil is any neutral, nonpolar chemical substance"
## eat      "eat"      "Eating (also known as consuming) is the ingestion "
## stream   "stream"   "A stream is a body of water with a current, confin"
## gasoline "gasoline" "Gasoline /ˈɡæsəliːn/, also known as petrol /ˈpɛtrə"
## engine   "engine"   "An engine or motor is a machine designed to conver"
## spoon    "spoon"    "A spoon is a utensil consisting of a small shallow"
```

I can then use the `tm` package to build a corpus of each document's text. I also want to include the assassin word's document text in the corpus as it will be relevant later when choosing clues.


```r
library(tm)

assassin_df = data.frame(codename = assassin, text = read_definition(assassin))

corpus = Corpus(VectorSource(rbind(spymaster, assassin_df)$text))
corpus
```

```
## <<VCorpus>>
## Metadata:  corpus specific: 0, document level (indexed): 0
## Content:  documents: 9
```

It is then straightforward to create a term-document matrix from this corpus.


```r
tdm = TermDocumentMatrix(corpus, control = list(tolower = TRUE,
                                                removePunctuation = TRUE,
                                                stopwords = TRUE))

tdm = as.matrix(tdm)
colnames(tdm) = c(red_codenames, assassin)

tdm[sample(1:nrow(tdm), 5), ]
```

```
##              Docs
## Terms         water plate oil eat stream gasoline engine spoon fire
##   extend          0     0   0   0      0        1      0     0    0
##   attributing     1     0   0   0      0        0      0     0    0
##   usaaf           0     0   0   0      0        1      0     0    0
##   olefins         0     0   0   0      0        6      0     0    0
##   occurring       1     0   0   0      0        1      0     0    1
```

Each row is a term and each column is a document. The value in the matrix is the term's frequency of occurrence in the given document.

## Determine similarities between each document

To determine how similar one document is to another, I calculate their [cosine similarities](https://en.wikipedia.org/wiki/Cosine_similarity) with the term-document matrix. Since each document is represented by a vector of term frequencies, I can determine the cosine similarity between each pair of documents with these vectors. In short, the more terms a pair of documents have in common, the higher their similarity. The cosine similarity between two documents $A$ and $B$ is defined as

$$similarity(\vec{A}, \vec{B}) = \frac{\sum_{i=1}^{n}A_iB_i}{\sqrt{\sum_{i=1}^{n}A_i^2}\sqrt{\sum_{i=1}^{n}B_i^2}}$$

where $A_i$ is the frequency of term $i$ in document $A$, $B_i$ is the frequency of term $i$ in document $B$, and $n$ is the number of terms in the corpus.

This is easy to compute with the `lsa` package, which provides a `cosine()` function. I'm omitting the assassin word from the similarity matrix as I'm only interested in clustering the red team's words. I'll bring the assassin word back into consideration when I'm determining the best clues.


```r
library(lsa)

c = cosine(tdm[, colnames(tdm) != assassin])
c
```

```
##               water      plate        oil        eat     stream   gasoline
## water    1.00000000 0.08363562 0.15250742 0.08003421 0.23758316 0.10927021
## plate    0.08363562 1.00000000 0.11167564 0.18124857 0.11126508 0.09358231
## oil      0.15250742 0.11167564 1.00000000 0.07728832 0.10376473 0.24642324
## eat      0.08003421 0.18124857 0.07728832 1.00000000 0.07347232 0.08069255
## stream   0.23758316 0.11126508 0.10376473 0.07347232 1.00000000 0.10365430
## gasoline 0.10927021 0.09358231 0.24642324 0.08069255 0.10365430 1.00000000
## engine   0.12203590 0.08647321 0.10815715 0.05883878 0.08661928 0.28600772
## spoon    0.09087910 0.27935231 0.13588511 0.13450619 0.13447126 0.11022702
##              engine      spoon
## water    0.12203590 0.09087910
## plate    0.08647321 0.27935231
## oil      0.10815715 0.13588511
## eat      0.05883878 0.13450619
## stream   0.08661928 0.13447126
## gasoline 0.28600772 0.11022702
## engine   1.00000000 0.08956788
## spoon    0.08956788 1.00000000
```

`c` is a matrix of cosine similarities. For example, the cosine similarity between `plate` and `spoon` is 0.2793523.

## Determine the most natural clustering of these documents with hierarchical clustering

With a document similarity matrix, I can use a clustering algorithm to figure out the best way to group these words. I decided to use hierarchical clustering, which expects a distance matrix. The Wikipedia article on cosine similarity suggests the following for converting cosine similarity to [angular distance](https://en.wikipedia.org/wiki/Cosine_similarity#Angular_distance_and_similarity):

$$distance(\vec{A}, \vec{B}) = \frac{2 \cdot cos^{-1}(similarity(\vec{A}, \vec{B}))}{\pi}$$


```r
d = as.dist(2 * acos(c) / pi)
d
```

```
##              water     plate       oil       eat    stream  gasoline
## plate    0.9466936                                                  
## oil      0.9025304 0.9287565                                        
## eat      0.9489941 0.8839723 0.9507476                              
## stream   0.8472896 0.9290195 0.9338222 0.9531839                    
## gasoline 0.9302972 0.9403364 0.8414894 0.9485736 0.9338929          
## engine   0.9221154 0.9448806 0.9310101 0.9625204 0.9447873 0.8153434
## spoon    0.9420646 0.8197605 0.9132244 0.9141104 0.9141328 0.9296844
##             engine
## plate             
## oil               
## eat               
## stream            
## gasoline          
## engine            
## spoon    0.9429028
```

`d` is a distance matrix of class `dist`. Passing this distance matrix to `hclust()` will run the [hierarchical agglomerative clustering](https://en.wikipedia.org/wiki/Hierarchical_clustering#Agglomerative_clustering_example) algorithm and produce a dendogram.


```r
tree = hclust(d)
plot(tree)
```

![plot of chunk dendogram]({{ site.url }}/images/spymaster-dendogram-1.png)

In hierarchical agglomerative clustering, each observation starts in its own cluster and at each iteration one observation / cluster is joined with another until there is only one cluster. The tree above shows at what point these merges occurred. Where you cut this tree determines the clusters, and the `cutree()` function allows us to cut the tree such that it produces $k$ clusters. The value of `cutree()` is a named vector of cluster assignments. For example, if $k = 3$:


```r
cuts = cutree(tree, k = 3)
cuts
```

```
##    water    plate      oil      eat   stream gasoline   engine    spoon 
##        1        2        3        2        1        3        3        2
```

I don't necessarily know $k$, so I cut the tree for $k = 2$ through $k = d - 1$, where $d$ is the number of documents, to determine which $k$ produces the highest mean [silhouette](https://en.wikipedia.org/wiki/Silhouette_(clustering)) metric. For any clustering, the silhouette metric is defined for each observation $i$ as

$$s(i) = \frac{b_i - a_i}{max(a_i, b_i)}$$

where $a_i$ is the average distance of observation $i$ from the rest of the observations in its cluster and $b_i$ is the minimum mean distance between $i$ and another cluster. Silhouette values close to 1 indicate the observation is in the correct cluster and values close to -1 indicate the observation belongs in another cluster.

If I look at the silhouette results from the cut I made earlier, I can see how well each observation fits into its assigned cluster.


```r
library(cluster)

sil = silhouette(cuts, d)
sil[1:8, ]
```

```
##      cluster neighbor  sil_width
## [1,]       1        3 0.07734257
## [2,]       2        1 0.09168796
## [3,]       3        1 0.03477175
## [4,]       2        1 0.05472427
## [5,]       1        2 0.09100033
## [6,]       3        1 0.11123188
## [7,]       3        1 0.06457176
## [8,]       2        1 0.06590169
```

I use the mean value of `sil_width` to determine the "goodness of fit" for different values of $k$.


```r
library(dplyr)

clusters = data.frame(k = 2:(length(red_codenames) - 1)) %>%
  group_by(k) %>%
  do(cuts = cutree(tree, .$k)) %>%
  mutate(mean_sil = mean(silhouette(cuts, d)[, "sil_width"]))

clusters
```

```
## Source: local data frame [6 x 3]
## Groups: <by row>
## 
##       k      cuts   mean_sil
##   <int>    <list>      <dbl>
## 1     2 <int [8]> 0.05299086
## 2     3 <int [8]> 0.07390403
## 3     4 <int [8]> 0.06192203
## 4     5 <int [8]> 0.05901358
## 5     6 <int [8]> 0.04023078
## 6     7 <int [8]> 0.01835767
```

With the highest mean value of `sil_width`, I assign those cuts as the documents' clusters.


```r
best = clusters %>% ungroup %>% top_n(1, mean_sil)

best
```

```
## Source: local data frame [1 x 3]
## 
##       k      cuts   mean_sil
##   <int>    <list>      <dbl>
## 1     3 <int [8]> 0.07390403
```

The value of $k$ that produces the highest mean silhouette value is $k = 3$.


```r
cuts = best$cuts[[1]]
spymaster$cluster = cuts

select(spymaster, codename, cluster)
```

```
##          codename cluster
## water       water       1
## plate       plate       2
## oil           oil       3
## eat           eat       2
## stream     stream       1
## gasoline gasoline       3
## engine     engine       3
## spoon       spoon       2
```

I can visualize these cluster assignments with [multidimensional scaling](https://en.wikipedia.org/wiki/Multidimensional_scaling#Classical_multidimensional_scaling), which will allow me to visualize the distance matrix in two dimensions using `cmdscale()`.


```r
library(ggplot2)

points = cmdscale(d)
spymaster$x = points[, 1]
spymaster$y = points[, 2]

ggplot(spymaster) + geom_text(aes(x = x, y = y, label = codename, color = factor(cluster)))
```

![plot of chunk clusters]({{ site.url }}/images/spymaster-clusters-1.png)

## Find the best one-word clue for each cluster

Now that I've determined a natural clustering of words, I need to find the best one-word clues to get the red team to guess the words in each of the clusters. In Codenames, clues consist of one word and one number. The number indicates how many words on the board the spymaster is associating with that clue.

The candidates for clues are all the words in the original corpus minus the words that are against the rules; i.e. any words that are among the words on the board.


```r
terms = row.names(tdm)
banned = vapply(terms,
                function(x) {any(grepl(x, board)) |
                             any(sapply(board, function(y) grepl(y, x)))},
                logical(1))

tdm = tdm[!banned, ]
```

My strategy is to find clues that are the most concentrated in one cluster more than any other cluster and then, within that cluster, that are spread out the most evenly among the codenames in the cluster. The intuition is that it will be easiest for the guessers to associate the clue with the correct codenames if the clue is most associated with only a single cluster yet spread out evenly among the codenames in that cluster.

To accomplish this I decided to use the [Herfindahl index](https://en.wikipedia.org/wiki/Herfindahl_index), which in the context of economics is a measure of competition among firms in a market based on their market shares. The more monopolistic the market, the higher the index, and the closer the market is to perfect competition, the lower the index. The Herfindahl index is calculated as

$$H = \sum_{i=1}^{n} s_{i}^{2}$$

where $s_i$ is the market share of firm $i$ in the market and $n$ is the number of firms in the market. This can be normalized such that it's between $0$ and $1$. In this particular case, I want to treat a one-firm market as perfectly competitive (I'll touch on why later).

$$H^{*} =
\begin{cases}
  \frac{H - 1/n}{1 - 1/n} & n > 1 \\
  0 & n = 1
\end{cases}
$$


```r
herfindahl_index = function(p) {
  n = length(p)
  if (n == 1) {return(0)}
  h = sum(p ^ 2)
  h_n = (h - 1 / n) / (1 - 1 / n)
  return(h_n)
}
```

Let `a` be a highly monopolistic market and `b` a market in nearly perfect competition. We can see the Herfindahl index is a good measure of concentration; that is, market `a` has a high Herfindahl index because the market share is very concentrated and market `b` has a low Herfindahl index because the market share is more evenly spread out.


```r
a = c(0.9, 0.05, 0.04, 0.01)
b = c(0.2, 0.3, 0.25, 0.25)

herfindahl_index(a)
```

```
## [1] 0.7522667
```

```r
herfindahl_index(b)
```

```
## [1] 0.006666667
```

This index can be applied to my problem: I want to identify clues that are highly concentrated in one cluster but are evenly spread out across the codenames in that cluster. In other words, I want clues...

With a high cross-cluster Herfindahl index,

$$
H_{cluster}(c) = \sum_{i=1}^k \bigg(\frac{m_{ci}}{\sum_{i=1}^k m_{ci}}\bigg)^2
$$

where $m_{ci}$ is the mean number of (normalized) occurrences of clue $c$ in cluster $i$ and $k$ is the number of clusters. I'm using the mean of normalized occurrences instead of the sum so that clusters with more observations aren't arbitrarily weighed higher than clusters with fewer observations.

And with a low cross-document-within-cluster Herfindahl index,

$$
H_{document}(c, i) = \sum_{j=1}^d \bigg(\frac{r_{cj}}{\sum_{j=1}^d r_{cj}}\bigg)^2
$$

where $r_{cj}$ is the normalized number of occurrences of clue $c$ in document $j$ and $d$ is the number of documents. I'm using the normalized number of occurrences so that longer documents aren't arbitrarily weighed higher than shorter documents.

Before I get started calculating these, I need to convert my term-document matrix from wide to long format, include the cluster assignments, and normalize the frequencies. I put the assassin word into its own cluster so that I can omit clues that are concentrated highly in the document for the assassin word, `fire`.


```r
library(tidyr)

normalize = function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

td = as.data.frame(t(tdm))
td$document = row.names(td)

assassin_cluster = max(cuts) + 1
cuts = c(cuts, c("fire" = assassin_cluster))
td$cluster = cuts

td = td %>%
  gather(term, r_cj, -document, -cluster) %>%
  select(document, cluster, clue = term, r_cj) %>%
  group_by(document) %>%
  mutate(r_cj = normalize(r_cj))
```

Let's choose a potential clue "fuel" and follow it through the calculations of the above metrics.


```r
follow = "fuel"

filter(td, clue == follow)
```

```
## Source: local data frame [9 x 4]
## Groups: document [9]
## 
##   document cluster   clue       r_cj
##      <chr>   <dbl> <fctr>      <dbl>
## 1    water       1   fuel 0.02702703
## 2    plate       2   fuel 0.00000000
## 3      oil       3   fuel 0.56250000
## 4      eat       2   fuel 0.04166667
## 5   stream       1   fuel 0.00000000
## 6 gasoline       3   fuel 1.00000000
## 7   engine       3   fuel 0.37500000
## 8    spoon       2   fuel 0.00000000
## 9     fire       4   fuel 0.75000000
```

I can use `dplyr`'s data manipulation methods to calculate $H_{cluster}$ and $H_{document}$ across all the potential clues for each cluster.

To calculate $H_{document}$ I group by `clue` and `cluster`.


```r
clues = td %>%
  group_by(clue, cluster) %>%
  mutate(m_ci = mean(r_cj), h_d = herfindahl_index(r_cj / sum(r_cj)))

filter(clues, clue == follow)
```

```
## Source: local data frame [9 x 6]
## Groups: clue, cluster [4]
## 
##   document cluster   clue       r_cj       m_ci        h_d
##      <chr>   <dbl> <fctr>      <dbl>      <dbl>      <dbl>
## 1    water       1   fuel 0.02702703 0.01351351 1.00000000
## 2    plate       2   fuel 0.00000000 0.01388889 1.00000000
## 3      oil       3   fuel 0.56250000 0.64583333 0.08220604
## 4      eat       2   fuel 0.04166667 0.01388889 1.00000000
## 5   stream       1   fuel 0.00000000 0.01351351 1.00000000
## 6 gasoline       3   fuel 1.00000000 0.64583333 0.08220604
## 7   engine       3   fuel 0.37500000 0.64583333 0.08220604
## 8    spoon       2   fuel 0.00000000 0.01388889 1.00000000
## 9     fire       4   fuel 0.75000000 0.75000000 0.00000000
```

To calculate $H_{cluster}$ I group by `term`.


```r
clues = clues %>%
  select(-r_cj, -document) %>%
  distinct(.keep_all = TRUE) %>%
  group_by(clue) %>%
  mutate(h_c = herfindahl_index(m_ci / sum(m_ci)))

filter(clues, clue == follow)
```

```
## Source: local data frame [4 x 5]
## Groups: clue [1]
## 
##   cluster   clue       m_ci        h_d       h_c
##     <dbl> <fctr>      <dbl>      <dbl>     <dbl>
## 1       1   fuel 0.01351351 1.00000000 0.3117274
## 2       2   fuel 0.01388889 1.00000000 0.3117274
## 3       3   fuel 0.64583333 0.08220604 0.3117274
## 4       4   fuel 0.75000000 0.00000000 0.3117274
```

At this point I want to throw out any clues that have the highest concentration in cluster 4, which consists solely of the assassin word `fire`. The clue we've been following so far, "fuel," should be thrown out because its mean number of normalized occurrences is highest in the assassin cluster and I don't want the red team to guess `fire` from the clue "fuel."


```r
dangerous = clues %>%
  mutate(max_m_ci = max(m_ci)) %>%
  filter(cluster == assassin_cluster, m_ci == max_m_ci)

clues = filter(clues, !(clue %in% dangerous$clue))
```

With dangerous clues thrown out, I am now trying to maximize $H_{cluster}$ and minimize $H_{document}$. To accomplish this I maximize the difference between $H_{cluster}$ and $H_{document}$ and multiply this difference by the mean normalized frequency of the clue in the cluster.

$$weight(c, i) = m_{ci} \cdot (H_{cluster}(c) - H_{document}(c, i))$$

This is why I wanted to treat markets with only one firm, or clusters with only one observation, as perfectly competitive (a Herfindahl index of 0): clusters with only one codename would simply choose the clue with the highest frequency of occurrence in that codename's document.

Then, for each cluster, I want the clue with the highest weight.


```r
clues = clues %>%
  group_by(cluster) %>%
  mutate(weight = m_ci * (h_c - h_d)) %>%
  top_n(1, weight) %>%
  select(clue, cluster, weight) %>%
  filter(cluster != assassin_cluster)

clues
```

```
## Source: local data frame [3 x 3]
## Groups: cluster [3]
## 
##     clue cluster    weight
##   <fctr>   <dbl>     <dbl>
## 1   bowl       2 0.2500000
## 2 diesel       3 0.1534926
## 3  river       1 0.3516484
```

I add these to the `spymaster` data.frame to get a more literal representation of what the clues will be: one word plus a number of how many words on the board the spymaster is associating with that clue.


```r
spymaster = left_join(spymaster, clues, by = "cluster")

select(spymaster, codename, cluster, clue)
```

```
##   codename cluster   clue
## 1    water       1  river
## 2    plate       2   bowl
## 3      oil       3 diesel
## 4      eat       2   bowl
## 5   stream       1  river
## 6 gasoline       3 diesel
## 7   engine       3 diesel
## 8    spoon       2   bowl
```

This approach has found clues that most reasonable guessers should be able to associate with the correct codenames on the board. In particular, by throwing out "fuel," which was too similar to the assassin word `fire`, it then found an acceptable alternative "diesel" that would make the red team's guessers think of `oil`, `engine`, and `gasoline` but not necessarily `fire`.

The clues the spymaster should actually read aloud to its teammates are:


```r
spymaster %>%
  group_by(clue) %>%
  summarize(number = n())
```

```
## Source: local data frame [3 x 2]
## 
##     clue number
##   <fctr>  <int>
## 1   bowl      3
## 2 diesel      3
## 3  river      2
```

## Taking it further

Some things I didn't consider were the opposing team's words and updating the spymaster with the latest information. The former could have been taken care of in a similar way as the assassin word. The latter refers to the fact that when words are successfully guessed they are covered up, which changes what words are allowed as clues. For example, the other day I was playing as spymaster and I had the codenames `wake` and `mass`. I wanted to give the clue "church," but `church` was actually on the board as the other team's codename. Once the other team successfully guessed `church` from their spymaster's clue, it was covered and I was able to use "church" as a clue for my team. If I were to productionize this, I would recalculate the best clues each turn taking the latest information into account. In addition, your team will only get a fraction of the words correct per turn in most cases, so the spymaster would need to recalculate the best clues given this information as well.
