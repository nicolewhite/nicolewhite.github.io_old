---
layout: default
title: Undersampling and Oversampling in R
---
# Undersampling and Oversampling in R

In many domains such as insurance fraud or mass mailings, researchers are attempting to predict an outcome that occurs extremely rarely in the population. For example, if an offer is sent in the mail to 100,000 people but only 200 respond, a simple random sample of this data is likely to contain very few observations where the customer responded to the offer.

Let the dependent variable, `response`, be 1 if the customer responded to the offer and 0 otherwise. One might use logistic regression or classification trees to build a model for estimating the probability of response given certain customer attributes. To do so, however, the researcher most likely wants to take samples of the dataset in order to have 1) a training dataset for building the model and 2) a test dataset for evaluating the model, as it is often a good idea to test models on data that was not used in the model-building process. 
 
The problem, though, is that the outcome the researcher is trying to predict, `response = 1`, occurs very rarely. This can be overcome by either oversampling the positive observations (`response = 1`) or by undersampling the negative observations (`response = 0`). Of course, this means we will be sampling _with replacement_, where some observations might occur more than once in the sample. This resampling is only done on the training dataset, since it is mostly agreed that it is best for the test dataset to closely resemble reality, as testing a model on a more realistic dataset is a better indication of its value.

Consider a dataset `mailing_train.csv` that has been parsed out of the population to comprise the training dataset. The dependent variable, `response`, is in the first column. The first thing we want to do is look at the percentage of response in the dataset:

```r
df = data.frame(response = c(rep(0, 15), rep(1, 5)), 
                x = runif(20, 0, 1),
                y = runif(20, 5, 10),
                z = runif(20, 100, 500))

df

#    response         x        y        z
# 1         0 0.3283922 6.810243 366.5927
# 2         0 0.6538655 5.264453 288.4032
# 3         0 0.3667321 8.169047 497.3499
# 4         0 0.2666914 7.151242 229.2888
# 5         0 0.7747729 8.563728 238.0421
# 6         0 0.4665078 7.536809 415.6771
# 7         0 0.2555748 6.640499 408.9797
# 8         0 0.7217887 5.091763 397.2549
# 9         0 0.2235010 9.668857 357.8915
# 10        0 0.4005695 7.985860 477.2930
# 11        0 0.3148380 9.195862 153.9309
# 12        0 0.2911229 9.613923 422.8834
# 13        0 0.9013784 5.256535 341.7850
# 14        0 0.2187492 5.052001 377.5179
# 15        0 0.7506786 8.905985 332.8203
# 16        1 0.4491956 5.323132 128.7961
# 17        1 0.8169173 5.823563 343.8081
# 18        1 0.1846849 5.343741 124.5553
# 19        1 0.7947691 7.317320 461.9072
# 20        1 0.2796422 6.321939 290.5473
```

In this example, only five people in the training dataset responded to our mail offer. Let `x`, `y`, and `z` be attributes of each customer. As mentioned earlier, we can either oversamle the observations where `response = 1` or undersample the observations where `response = 0`. First, we'll get the row numbers of all observations where `response = 1` (`pos`), get the row numbers of all observations where `response = 0` (`neg`), and get the total number of observations in the training dataset (`n`):

```r
n = nrow(df)
pos = which(df$response == 1)
neg = which(df$response == 0)

n
# [1] 20

pos
# [1] 16 17 18 19 20

neg
# [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
```

Now we'll use the `sample()` function to resample this dataset. The usage of `sample()` is `sample(x, size, replace = FALSE)`, where `x` is a vector of elements from which to draw the sample, `size` is how many elements to gather, and `replace` indicates whether or not to sample with replacement.

For oversampling, we want to concatenate two samples to comprise a sample of size `n`:

* A sample from `pos` of size `length(neg)` with replacement
* A sample from `1:n` of size `length(pos)` with replacement

We'll assign the row numbers of the observations that ended up in the sample to `over`:

```r
over = c(sample(pos, length(neg), replace = TRUE),
         sample(1:n, length(pos), replace = TRUE))
		 
over

# [1] 18 17 16 17 17 17 18 20 19 20 16 18 18 20 18  1 14  1 12  5
```

Then we can use `over` to subset the original dataset:

```r
train.over = df[over, ]
```

For undersampling, we want to concatenate two samples to comprise a sample of size `n`:

* A sample from `neg` of size `length(pos)` with replacement
* A sample from `1:n` of size `length(neg)` with replacement

We'll assign the row numbers of the observations that ended up in the sample to `under`:

```r
under = c(sample(neg, length(pos), replace = TRUE),
		  sample(1:n, length(neg), replace = TRUE))
		  
under
# [1] 12 13 10  9 15 19  3 18 15  8  7  4  3  8  3 20 19 17 13  8
```


