---
layout: default
title: Why do we divide by n - 1 when calculating the sample variance?
---
In my marketing class the other day, the professor briefly touched on why we divide by \\( n - 1 \\) when calculating the sample variance. He explained that we divide by \\( n - 1 \\), rather than \\( n \\), because we've "lost a degree of freedom." I'd like to go a little deeper into why this is so, because I think it is actually quite intuitive and should be understood beyond the explanation of "dividing by \\( n - 1 \\) makes the sample variance an unbiased estimate of the population variance."

For the purposes of calculating a statistic, the [degrees of freedom](http://en.wikipedia.org/wiki/Degrees_of_freedom) can be thought of as "the number of independent pieces of information that go into the estimate of a parameter." In short, we need to know all n observations in order to calculate the sample mean, but we only need to know \\( n - 1 \\) of the residuals,

\\[ x_{i} - \bar{x} \\]

in order to calculate the sample variance.

Consider the following sample of \\( n = 3 \\) observations:

\\[ x_1 = 3 \\ x_2 = 4 \\ x_3 = 5 \\]

### Sample Mean
The sample mean is the sum of the observations divided by the degrees of freedom, \\( DF \\), where the degrees of freedom is the number of observations we need to know in order to calculate the sum in the numerator:

\\[ \bar{x} = \frac{\sum\limits_{i = 1}^n x_{i}}{DF} \\]

Clearly, we need to know all \\( DF = n \\) observations in order to calculate their sum:

\\[ \begin{align*} \bar{x} & = \frac{\sum\limits_{i = 1}^n x_{i}}{n} & = \frac{3 + 4 + 5}{3} = 4 \end{align*} \\]

### Sample Variance
The sample variance is the sum of squared residuals divided by the degrees of freedom, \\( DF \\), where the degrees of freedom is the number of residuals we need to know in order to calculate the sum of squared residuals in the numerator:

\\[ s^2 = \frac{\sum\limits_{i = 1}^n (x_{i} - \bar{x})^2}{DF} \\]

It is important at this point to note that the sum of residuals is necessarily 0:

\\[ \sum\limits_{i=1}^n (x_{i} - \bar{x}) = 0 \\]

In our example, it is true that:

\\[ (x_{1} - \bar{x}) + (x_{2} - \bar{x}) + (x_{3} - \bar{x}) = 0 \\]

Because we know the sum of the residuals is zero, we can compute the third residual just from knowing the first two:

\\[ \\ 0 = (x_{1} - \bar{x}) + (x_{2} - \bar{x}) + (x_{3} - \bar{x}) \\ 0 = (3 - 4) + (4 - 4) + (x_{3} - \bar{x}) \\ 0 = -1 + 0 + (x_{3} - \bar{x}) \\ \\ \Rightarrow (x_{3} - \bar{x}) = 1 \\]

Hopefully you are convinced by now that we only need to know \\( DF = (n - 1) \\) of the residuals in order to calculate the sum of squared residuals. The unbiased sample variance is thus:

\\[ \begin{align*} s_{n - 1}^2 & = \frac{\sum\limits_{i = 1}^n (x_{i} - \bar{x})^2}{n - 1} \\ \\ & = \frac{(3 - 4)^2 + (4 - 4)^2 + (x_{3} - \bar{x})^2}{3 - 1} \\ \\ & = \frac{(-1)^2 + 0^2 + 1^2}{2} \\ \\ & = \frac{2}{2} \\ \\ & = 1 \end{align*} \\]

There are only \\( n - 1 \\) residuals that are free to vary, and thus there are only \\( n - 1 \\) degrees of freedom. The \\( n^{th} \\) residual is not free to vary; it is constrained to the value that causes the sum of the residuals to be zero.