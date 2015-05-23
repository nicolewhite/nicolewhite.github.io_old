---
title: "Understanding Waiting Times Between Events with the Poisson and Exponential Distributions"
output: pdf_document
layout: post
---



# Understanding Waiting Times Between Events with the Poisson and Exponential Distributions

A webhook POSTs to our database each time a particular event occurs on our website. I was mindlessly monitoring the log files one day and noticed it had been roughly 90 seconds since our database had been hit by this request. Before worrying, though, I wondered how rare that observation is. What is the likelihood of waiting 1.5 minutes for the next request?

This is a probability problem that can be solved with an understanding of Poisson processes and the exponential distribution. A Poisson process is any process where independent events occur at constant known rate, e.g. babies are born at a particular hospital at a rate of 2 per hour, or calls come into a call center at a rate of 10 per minute. The exponential distribution is the probability distribution that models the waiting times between these events, e.g. the times between calls at the call center are exponentially distributed. To model Poisson processes and exponental distributions, we need to know two things: a time-unit \\(t\\) and a rate \\(\lambda\\). 

## Poisson Distribution

Let's start with the Poisson distribution: If we let \\(N(t)\\) denote the number of events that occur between now and time \\(t\\), then the probability that \\(n\\) events occur within the next \\(t\\) time-units, or \\(P(N(t) = n)\\), is

$$
  P(N(t) = n) = \frac{(\lambda t)^n e^{-\lambda t}}{n!}
$$

Let's say I've crunched the numbers and found that we receive an average of 2 requests from this webhook per minute. Thus, the time-unit \\(t\\) is one minute and the rate \\(\lambda\\) is 2. Knowing these, we can answer questions such as:

* What is the probability that we receive no requests in the next two minutes?


$$
  P(N(2) = 0) = \frac{(2 \cdot 2)^0 e^{-2 \cdot 2}}{0!} = e^{-4} = 0.0183156
$$

* What is the probability that we receive at least two requests in the next three minutes?


$$
\begin{aligned}
P(N(3) \geq 2) & = 1 - P(N(3) = 1) - P(N(3) = 0) \\\\
                       & = 1 - \frac{(2 \cdot 3)^1 e^{-2 \cdot 3}}{1!} - \frac{(2 \cdot 3)^0 e^{-2 \cdot 3}}{0!} \\\\
                       & = 1 - 6e^{-6} - e^{-6} \\\\
                       & = 1 - 7e^{-6} \\\\
                       & = 0.9826487 \\\\
\end{aligned}
$$

For those who prefer reading code:

```python
from math import pow, exp, factorial

class Poisson:

    def __init__(self, rate):
        self.rate = rate

    def prob_exactly(self, n, t):
        rate = self.rate * t
        return pow(rate, n) * exp(-rate) / factorial(n)

    def prob_at_least(self, n, t):
        complements = range(n)
        total = 0.0

        for c in complements:
            p = self.prob_exactly(c, t)
            total += p

        return 1 - total

    def prob_at_most(self, n, t):
        return 1 - self.prob_at_least(n + 1, t)

pois = Poisson(2)
print pois.prob_exactly(0, 2)
print pois.prob_at_least(2, 3)
```

```
0.0183156388887
0.982648734763
```

## Exponential Distribution

Let's move onto the exponential distribution. As mentioned earlier, the waiting times between events in a Poisson process are exponentially distributed. The exponential distribution can be derived from the Poisson distribution: Let \\(X\\) be the waiting time between now and the next event. The probability that \\(X\\) is greater than \\(t\\) is identical to the probability that 0 events occur between now and time \\(t\\), which we already know:

$$
P(X > t) = P(N(t) = 0) = \frac{(\lambda t)^0 e^{-\lambda t}}{0!} = e^{-\lambda t}
$$

We also know that the probability of \\(X\\) being less than or equal to \\(t\\) is the complement of \\(X\\) being greater than \\(t\\):

$$
P(X \leq t) = 1 - P(X > t) = 1 - e^{-\lambda t}
$$

Thus, the distribution function of the waiting times between events in a Poisson process is \\(1 - e^{-\lambda t}\\). With this, and recalling that our time-unit \\(t\\) is one minute and our rate \\(\lambda\\) is 2 requests per minute, we can answer questions such as:

* What is the probability that the next request occurs within 15 seconds?



$$
P(X \leq 0.25) = 1 - e^{-2 \cdot 0.25} = 1 - e^{-0.5} = 0.3934693
$$

* What is the probability that the next request is between 15 and 30 seconds from now?



$$
\begin{aligned}
P(0.25 \leq X \leq 0.5) & = P(X \leq 0.5) - P(X \leq 0.25) \\\\
                             & = (1 - e^{-2 \cdot 0.5}) - (1 - e^{-2 \cdot 0.25}) \\\\
                             & = e^{-0.5} - e^{-1} \\\\
                             & = 0.2386512
\end{aligned}
$$

Again, for those who prefer reading code:

```python
from math import exp

class Exponential:

    def __init__(self, rate):
        self.rate = rate

    def prob_less_than_or_equal(self, t):
        rate = self.rate * t
        return 1 - exp(-rate)

    def prob_greater_than(self, t):
        return 1 - self.prob_less_than_or_equal(t)

    def prob_between(self, t1, t2):
        p1 = self.prob_less_than_or_equal(t1)
        p2 = self.prob_less_than_or_equal(t2)

        return p2 - p1

expo = Exponential(2)
print expo.prob_less_than_or_equal(0.25)
print expo.prob_between(0.25, 0.5)
```

```
0.393469340287
0.238651218541
```

## Answer

So, what is the probability that we wait 1.5 minutes for the next request?



$$
P(X > 1.5) = e^{-2 \cdot 1.5} = e^{-3} = 0.0497871
$$

The probability of waiting 1.5 minutes for the next request is 4.98%.

```python
expo = Exponential(2)
print expo.prob_greater_than(1.5)
```

```
0.0497870683679
```

For this particular example, we could have answered the question with the Poisson distribution by finding \\(P(N(1.5) = 0))\\). 

```python
pois = Poisson(2)
print pois.prob_exactly(0, 1.5)
```

```
0.0497870683679
```
