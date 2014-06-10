---
layout: post
comments: true
title: Scale Only the Continuous Variables in an R Data Frame.
category: R
---
# Scale Only the Continuous Variables in an R Data Frame

When performing a logistic regression, it is often that your dataset consists of a mixture of continuous and binary variables. In order to avoid numerically-unstable estimation, it is desirable to scale the continous variables in your dataset while leaving the binary variables alone. Consider the following data frame:

```r
df = data.frame(x = c(rep(0, 5), rep(1, 5)), 
                y = 11:20, 
                z = 21:30)

print(df)

# x  y  z
# 0 11 21
# 0 12 22
# 0 13 23
# 0 14 24
# 0 15 25
# 1 16 26
# 1 17 27
# 1 18 28
# 1 19 29
# 1 20 30
```

To obtain a logical vector indicating which columns are binary, we can use `apply()`:

```r
binary = apply(df, 2, function(x) {all(x %in% 0:1)})

print(binary)

#    x     y     z 
# TRUE FALSE FALSE 
```

`apply()` found all columns whose elements consist only of 0 and 1. Now we can subset the data using this logical vector. We want the continuous variables, though, so we use `!`:

```r
print(df[!binary])

#  y  z
# 11 21
# 12 22
# 13 23
# 14 24
# 15 25
# 16 26
# 17 27
# 18 28
# 19 29
# 20 30
```

Column `x` was not printed because it is not binary (`!binary`).

Now we can write a function that scales only the continuous variables in a data frame.

```r
scaleContinuous = function(data) {
  binary = apply(data, 2, function(x) {all(x %in% 0:1)}) 
  data[!binary] = scale(data[!binary])
  return(data)
}

scaleContinuous(df)

# x          y          z
# 0 -1.4863011 -1.4863011
# 0 -1.1560120 -1.1560120
# 0 -0.8257228 -0.8257228
# 0 -0.4954337 -0.4954337
# 0 -0.1651446 -0.1651446
# 1  0.1651446  0.1651446
# 1  0.4954337  0.4954337
# 1  0.8257228  0.8257228
# 1  1.1560120  1.1560120
# 1  1.4863011  1.4863011
```
