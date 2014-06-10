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
#        Happy Gloomy Sleepy
# Happy    0.4    0.4    0.2
# Gloomy   0.0    0.5    0.5
# Sleepy   0.1    0.3    0.6
```

\\(P\\) is the one-time-step transition probability matrix (in this example, a time-step is a day), where the \\((i, j)\\) entry indicates the probability that my mood one day from now will be in state \\(j\\) given that my mood is currently in state \\(i\\). For example, if I am gloomy today, then tomorrow there is a 50% chance that I will be gloomy and a 50% chance that I will be sleepy.

To get the two-time-step transition probability matrix, you raise the one-time-step transition probability matrix, \\(P\\), to the second power (\\(P^2\\)).

```r
library(expm)

p %^% 2

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

$$ \mu_{i} = \begin{bmatrix} 0.0877 & 0.3860 & 0.5263 \end{bmatrix} $$

Instead of raising \\(P\\) to sufficiently high powers, this steady-state distribution can be found more easily in a few ways, all of which come down to solving

$$ \mu P = \mu $$

for \\(\mu\\) with the constraint that \\(\sum\_{i} \mu_{i} = 1\\).

## Solve with System of Equations

\\( \mu P = \mu \\) can be written as a system of equations.

$$ 0.4 \mu\_0 + 0.0 \mu\_1 + 0.1 \mu\_2 = \mu\_0 $$
$$ 0.4 \mu\_0 + 0.5 \mu\_1 + 0.3 \mu\_2 = \mu\_1 $$
$$ 0.2 \mu\_0 + 0.5 \mu\_1 + 0.6 \mu\_2 = \mu\_2 $$

with the constraint that

$$ \mu\_0 + \mu\_1 + \mu\_2 = 1. $$

After some re-arranging, we can get this into the form \\(Ax = b\\) where we can solve for \\(x\\) with `R`'s [qr.solve](http://stat.ethz.ch/R-manual/R-devel/library/base/html/qr.html).

$$ (0.4 \mu\_0 - \mu\_0) + 0.0 \mu\_1 + 0.1 \mu\_2 = 0 $$
$$ 0.4 \mu\_0 + (0.5 \mu\_1 - \mu\_1) + 0.3 \mu\_2 = 0 $$
$$ 0.2 \mu\_0 + 0.5 \mu\_1 + (0.6 \mu\_2 - \mu\_2) = 0 $$
$$ \mu\_0 + \mu\_1 + \mu\_2 = 1 $$

$$ \Rightarrow $$

$$ -0.6\mu\_0 + 0.0 \mu\_1 + 0.1 \mu\_2 = 0 $$
$$ 0.4 \mu\_0 - 0.5 \mu\_1 + 0.3 \mu\_2 = 0 $$
$$ 0.2 \mu\_0 + 0.5 \mu\_1 - 0.4 \mu\_2 = 0 $$
$$ 1.0 \mu\_0 + 1.0 \mu\_1 + 1.0 \mu\_2 = 1 $$

$$ \Rightarrow $$

$$ \begin{bmatrix} -0.6 & 0.0 & 0.1 \\\ 0.4 & -0.5 & 0.3 \\\ 0.2 & 0.5 & -0.4 \\\ 1 & 1 & 1 \end{bmatrix} \times \begin{bmatrix} \mu\_0 \\\ \mu\_1 \\\ \mu\_2 \end{bmatrix} = \begin{bmatrix} 0 \\\ 0 \\\ 0 \\\ 1 \end{bmatrix} $$

$$ \Rightarrow $$

$$ Ax = b $$

It should be noted that \\(A\\) is equivalent to \\((P - I)^T\\) (where \\(I\\) is the [identity matrix](http://en.wikipedia.org/wiki/Identity_matrix)) with a row of 1s appended to the bottom.

In `R`, we can solve for \\(x\\) with the following:

```r
n = ncol(p)
A = t(p - diag(n))
A = rbind(A, rep(1, n))
b = c(rep(0, n), 1)

A
#        Happy Gloomy Sleepy
# Happy   -0.6    0.0    0.1
# Gloomy   0.4   -0.5    0.3
# Sleepy   0.2    0.5   -0.4
#          1.0    1.0    1.0

b
# [1] 0 0 0 1

mu = qr.solve(A, b)

mu
#     Happy    Gloomy    Sleepy 
# 0.0877193 0.3859649 0.5263158 
```

## Solve with Eigenvectors
A row vector that remains unchanged (or is a constant multiple of itself) when multiplied by a square matrix is a [left-eigenvector](http://en.wikipedia.org/wiki/Eigenvalues_and_eigenvectors#Left_and_right_eigenvectors). That is, a vector \\(v\\) that satisfies the equation

$$ vA = \lambda v $$

is a left-eigenvector of \\(A\\) where \\(\lambda\\) are the eigenvalues.

Because \\(\mu\\) is a solution to \\( \mu P = \mu \\), \\(\mu\\) is a left-eigenvector of the square matrix \\(P\\) corresponding to the eigenvalue \\(\lambda = 1\\). In `R`, the left-eigenvectors can be found by executing [eigen](http://stat.ethz.ch/R-manual/R-devel/library/base/html/eigen.html) on the transpose of \\(P\\).

```r
e = eigen(t(p))
first = Re(e$vectors[ ,1])

# Normalize.
mu = first / sum(first)

mu
# [1] 0.0877193 0.3859649 0.5263158
```

## Solve with Null Spaces

My favorite way to get the steady-state distribution is by finding the [basis](http://en.wikipedia.org/wiki/Basis_%28linear_algebra%29) of the [null space](http://en.wikipedia.org/wiki/Kernel_%28linear_algebra%29) of \\((P - I)^T\\), where \\(I\\) is the [identity matrix](http://en.wikipedia.org/wiki/Identity_matrix). Note that the null space of \\((P - I)^T\\) is equivalent to the [left null space](http://en.wikipedia.org/wiki/Kernel_linear_algebra#Left_null_space) of \\(P - I\\).

Rearranging \\(\mu P = \mu\\) yields

$$ \mu P - \mu = 0 $$

$$ \mu P - \mu I = 0 $$

$$ \mu (P - I) = 0 $$

$$ (\mu (P - I))^T = 0^T $$

$$ (P - I)^T \mu^T = 0^T $$

such that

$$ \mu^T \in Null((P - I)^T). $$

This might have been clear when you re-arranged the system of equations and set everything to 0.

Conveniently, the [pracma](http://cran.r-project.org/web/packages/pracma/index.html) package has a function [nullspace](http://www.inside-r.org/packages/cran/pracma/docs/nullspace) for finding the basis of a null space.

```r
library(pracma)

A = t(p - diag(n))
basis = nullspace(A)

# Normalize.
mu = basis / sum(basis)

mu
#           [,1]
# [1,] 0.0877193
# [2,] 0.3859649
# [3,] 0.5263158
```