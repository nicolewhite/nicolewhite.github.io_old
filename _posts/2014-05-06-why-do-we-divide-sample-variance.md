---
layout: default
title: Why do we divide by n - 1 when calculating the sample variance?
---
In my marketing class the other day, the professor briefly touched on why we divide by \\( n - 1 \\) when calculating the sample variance. He explained that we divide by \\( n - 1 \\), rather than \\( n \\), because we've "lost a degree of freedom." I'd like to go a little deeper into why this is so, because I think it is actually quite intuitive and should be understood beyond the explanation of "dividing by \\( n - 1 \\) makes the sample variance an unbiased estimate of the population variance."

For the purposes of calculating a statistic, the [degrees of freedom](http://en.wikipedia.org/wiki/Degrees_of_freedom) can be thought of as "the number of independent pieces of information that go into the estimate of a parameter." In short, we need to know all n observations in order to calculate the sample mean, but we only need to know \( n - 1 \\) of the residuals,

\\[ x_{i} - \bar{x} \\]

in order to calculate the sample variance.

Consider the following sample of \\( n = 3 \\) observations:

\\[ x_1 = 3 \\
	x_2 = 4 \\
	x_3 = 5 \\]

test