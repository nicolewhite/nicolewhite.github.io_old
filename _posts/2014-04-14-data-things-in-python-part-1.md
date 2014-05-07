---
layout: default
title: Data Things in Python Part I: Data Collection
---
Scrape Data from the Internet Using BeautifulSoup
=================================================

The Website
-----------
When a data analysis idea pops into my head, it's not typical that a pretty .CSV file containing all the data I want exists on the Internet. So I have to go get it myself. I recently scraped a dataset from http://www.airfleets.net/ using [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/bs4/doc/). This website has a lot of data, but I am only interested in obtaining the fleet composition of each airline.

Packages Used
-------------
```python
import requests
import csv
from bs4 import BeautifulSoup
import string
from unidecode import unidecode
```
