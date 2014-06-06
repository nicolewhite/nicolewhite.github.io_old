---
layout: post
title: Find the Steady State Distribution of a Transition Probability Matrix in R.
comments: true
category: R
---

# Find the Steady State Distribution of a Transition Probability Matrix in R

A Markov process consists of states and probabilities, where the probability of transitioning from one state to another depends only on the current state and not on the past; it is _memoryless_. A Markov process is often depicted as a transition probability matrix, where the \\((i, j) \\) entry of this matrix is the probability that the Markov process transitions to state \\(j \\) at the next time-step given that the process is currently in state \\( i \\).

Consider the following Markov process, where each state is my mood on a given day (assume these are mutually exclusive).

```r
p = matrix(c(0.4,0.0,0.1,
             0.4,0.5,0.3,
             0.2,0.5,0.6),
            nrow = 3,
            ncol = 3)

states = c("Happy", "Gloomy", "Sleepy")
colnames(p) = states
rownames(p) = states

p

#       Happy Gloomy Sleepy
# Happy    0.4    0.4    0.2
# Gloomy   0.0    0.5    0.5
# Sleepy   0.1    0.3    0.6
```

\\(P\\) is the one-time-step transition probability matrix (in this example, a time-step is a day), where the \\((i, j)\\) entry indicates the probability that my mood one day from now will be in state \\(j\\) given that my mood is currently in state \\(i\\). For example, if I am gloomy today, then tomorrow there is a 50% chance that I will be gloomy and a 50% chance that I will be sleepy.

To get the two-time-step transition probability matrix, you raise the one-time-step transition probability matrix, \\(P\\), to the second power (\\(P^2\\)).

```r
library(expm)

p2 = p %^% 2

p2

#        Happy Gloomy Sleepy
# Happy   0.18   0.42   0.40
# Gloomy  0.05   0.40   0.55
# Sleepy  0.10   0.37   0.53
```

\\(P^2\\) is the two-time-step transition probability matrix. The \\((i, j)\\) entry indicates the probability that my mood two days from now will be in state \\(j\\) given that my mood is currently in state \\(i\\). For example, if I am happy today, then two days from now there is an 18% chance that I will be happy, a 42% chance that I will be gloomy, and a 40% chance that I will be sleepy.

To get the \\(k\\)-time-step transition probability matrix, you raise the one-time-step probability matrix, \\(P\\), to the \\(k^{th}\\) power (\\(P^k\\)).

As you continue raising \\(P\\) to higher powers, you'll start to notice that the probabilities are converging.

```r
p %^% 5

#          Happy  Gloomy  Sleepy
# Happy  0.08886 0.38766 0.52348
# Gloomy 0.08675 0.38530 0.52795
# Sleepy 0.08824 0.38617 0.52559

p %^% 20

#            Happy    Gloomy    Sleepy
# Happy  0.0877193 0.3859649 0.5263158
# Gloomy 0.0877193 0.3859649 0.5263158
# Sleepy 0.0877193 0.3859649 0.5263158
```

For Markov processes that are finite, [irreducible](http://en.wikipedia.org/wiki/Markov_chain#Reducibility), and [aperiodic](http://en.wikipedia.org/wiki/Markov_chain#Periodicity), there is a long-run equilibrium that is reached despite the starting state. For example, when looking at \\(P^{20}\\), the chance that I will be sleepy 20 days from now is 52.63% regardless of what my mood is today.

This equilibrium is called the steady-state distribution of the Markov process and is typically denoted by \\(\mu\\) or \\(\pi\\). I prefer \\(\mu\\). The steady-state distribution can be interpreted as the fraction of time the Markov process spends in state \\(i\\) in the long-run. In this example, after raising \\(P\\) to a high enough power, we can see that the steady-state distribution is

$$ \mu_{i} = [0.0877, 0.3860, 0.5263] $$

Instead of raising \\(P\\) to sufficiently high powers, this steady-state distribution can be found more easily in a few ways, all of which come down to solving

$$ \mu P = \mu $$

for \\(\mu\\) with the constraint that \\(\sum \mu_{i} = 1\\).

This can be solved with eigenvectors (see `R`'s [eigen](http://stat.ethz.ch/R-manual/R-devel/library/base/html/eigen.html)), systems of equations (see `R`'s [solve](http://stat.ethz.ch/R-manual/R-devel/library/base/html/solve.html)), or with my favorite: by finding the [basis](http://en.wikipedia.org/wiki/Basis_%28linear_algebra%29) of the [null space](http://en.wikipedia.org/wiki/Kernel_%28linear_algebra%29) of \\(P - I\\), where \\(I\\) is the [identity matrix](http://en.wikipedia.org/wiki/Identity_matrix).

Rearranging \\(\mu P = \mu\\) yields

$$ \mu P - \mu = 0 $$

$$ \mu P - \mu I = 0 $$

$$ \mu (P - I) = 0 $$

such that

$$ \mu \in Null(P - I). $$

This is also obvious when starting down the systems of equations route, since you are solving the system

$$ 0.4a + 0.4b + 0.2c = a $$
$$ 0.0a + 0.5b + 0.5c = b $$
$$ 0.1a + 0.3b + 0.6c = c $$

for \\(a\\), \\(b\\), and \\(c\\) (this would be a non-normalized solution).

Rearranging the above system yields

$$ (0.4a - a) + 0.4b + 0.2c = 0 $$
$$ 0.0a + (0.5b - b) + 0.5c = 0 $$
$$ 0.a1 + 0.3b + (0.6c - c) = 0 $$

which also shows that the solution belongs to the null space of \\(P - I\\).

Conveniently, the MASS package has a function [Null](http://stat.ethz.ch/R-manual/R-patched/library/MASS/html/Null.html) for finding the basis of a null space.

```r
library(MASS)

n = ncol(p)

ss = Null(p - diag(n))

ss = ss / sum(ss)

ss

#           [,1]
# [1,] 0.0877193
# [2,] 0.3859649
# [3,] 0.5263158
```

Compare the values of `ss` to the values of \\(P^{20}\\).







