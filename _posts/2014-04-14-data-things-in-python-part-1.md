---
layout: default
title: Data Things in Python Part I: Data Collection
---
# Scrape Data from the Internet Using BeautifulSoup

## The Website
When a data analysis idea pops into my head, it's not typical that a pretty .CSV file containing all the data I want exists on the Internet. So I have to go get it myself. I recently scraped a dataset from http://www.airfleets.net/ using [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/bs4/doc/). This website has a lot of data, but I am only interested in obtaining the fleet composition of each airline.

## Packages Used
```python
import requests
import csv
from bs4 import BeautifulSoup
import string
from unidecode import unidecode

```

## Get name, location, and status for each airline.
The webpage I need to look at to accomplish this is: http://www.airfleets.net/recherche/airline.htm. They have the webpages for the list of airlines separated by first letter, and then separated by several pages within each letter. I'll want to loop through each letter of the alphabet, and then, within that loop, I'll want to loop through each page of the relevant letter. That means I need to figure out how many pages each letter has.

Using the letter a as an example, let's examine the HTML from http://www.airfleets.net/recherche/list-airline-a_0.htm. After looking around, I find the following line in the HTML source code:

```html
<a class="page2">Page 1/35</a>
```

The page count can be found within the first `a` tag with `class="page2"`. Knowing this, I can build a list of `(letter, page)` tuples over which I can iterate later:

```python
# Create a list of letters a through z.
letters = list(string.lowercase)

# Initialize empty list for holding the page counts.
pages = []

for letter in letters:
    # Go to the first page for the current letter.
    url = "http://www.airfleets.net/recherche/list-airline-%s_0.htm" % letter
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'lxml')
    
    # Find how many pages there are for the current letter.
    a = soup.find('a', attrs = {'class': 'page2'})
    p = int(a.string.split('/')[1])
    
    # Append page count to pages list.
    pages.append(p)

# Create a list of tuples (letter, page).
letters_pages = zip(letters, pages)

print(letters_pages)

# Output:
# [('a', 35), ('b', 7), ('c', 11), ('d', 4), ('e', 7), ('f', 6), ('g', 5), ('h', 4), ('i', 5), ('j', 4), ('k', 3), ('l', 5), ('m', 8), ('n', 6), ('o', 3), ('p', 7), ('q', 1), ('r', 5), ('s', 15), ('t', 10), ('u', 2), ('v', 4), ('w', 3), ('x', 1), ('y', 1), ('z', 1)]
```

Letter `a` has 35 pages, letter `b` has 7 pages, letter `c` has 11 pages, etc. Now that we have this, we need to look at the HTML that contains the information we actually want to scrape. Using http://www.airfleets.net/recherche/list-airline-a_0.htm as an example again, the HTML source code for the first row in the table is:

```html
<tr class="trtab" valign=center>
    <td width="30%" class="tdtexten">
        <a class="lien" title="Go to AB Airlines fleet"  href="../flottecie/AB Airlines.htm">AB Airlines</a><br>
        <a title="Go to AB Airlines fleet"  href="../flottecie/AB Airlines.htm"><img border="0" src="../cie/AB Airlines.jpg" width="75" height="25"></a>
    </td>
    <td width="30%" class="tdtexten"><img src="../images/flags/G.gif" height="12">  United Kingdom</td>
    <td align="left" width="40%" class="tdtexten">
        <a class="lien" href="../flottecie/AB Airlines.htm"><img border="0" src="../images/noactive.gif" width="12" height="12"> inactive</a> (with 
        <a href="../recherche/supported-plane.htm" class="lien">supported aircraft</a>)
    </td>
</tr>
```

The `tr` tags with `class="trtab"` contain all the data I want for a single observation (airline name, airline location, and airline status), and I'll be able to find all these `tr` tags on each page using BeautifulSoup's `.find_all()` function. After I find the data for the observation, I write it to a `.CSV` file called `airlines.csv`:

```python
# Open CSV for data write.
with open('airlines.csv', 'wb') as file:
    writer = csv.writer(file, delimiter = ',', quotechar = '"')
    # Create header row.
    writer.writerow(["airline", "country", "status"])

    for letter, max_page in letters_pages:
        # Loop through each page of the current letter.
        for i in range(1, max_page + 1):
            url = "http://www.airfleets.net/recherche/list-airline-%s_%s.htm" % (letter, str((i - 1) * 20)) # Number in URL is in increments of 20.
            r = requests.get(url)
            soup = BeautifulSoup(r.text, 'lxml')

            # Loop through each row of the table on the current page.
            for tr in soup.find_all('tr', attrs = {'class': 'trtab'}):
                try:
                    airline = unidecode(tr.contents[1].a.string)
                    country = unidecode(str(tr.contents[3]).split('>  ')[1].replace('</td>', ''))
                    if(str(tr.contents[5]).find('inactive') != -1):
                        status = 'Inactive'
                    else:
                        status = 'Active'

                    # Add data to CSV.
                    writer.writerow([airline, country, status])

                # Add exception for troubleshooting purposes.
                except Exception:
                    print("There was an error on page %s for letter %s") % (str(i), letter)
                    print(tr.contents)
                    pass
```

## Get aircraft information.
The information for all the aircraft owned by the airlines can be found at http://www.airfleets.net/recherche/supported-plane.htm. Here, the list of aircraft is separated by model and then by several pages within each model. The process for scraping this data is similar. First, I'm going to get a list of all the model names, their respective URL chunks, and their respective page counts. For example, Airbus 300 information starts at http://www.airfleets.net/listing/a300-1.htm and has 12 pages of aircraft information. Thus, the first tuple will be `('Airbus 300', 'a300', 12)`. I want to get a tuple like this for each model and then store them in a list over which I can iterate later.

Again, let's look at some HTML. On the 'main' page, http://www.airfleets.net/recherche/supported-plane.htm, the information for the Airbus 300 can be found in the following source code:

```html
<td width="100%" class="tdtexten">
  <a class=lien href="../listing/a300-1.htm" title="Production list : Airbus A300">Airbus A300</a>
</td>
```

That means I can get the first two elements of the tuple, the model name and URL chunk, from the main page by finding the `td` tags with `class="tdtexten"`. But for the third element of the tuple, I need to follow the link `../listing/a300-1.htm` to the first page of the model to find its page count. Finding the page count is the same process as before, as it's located in the first `a` tag with `class="page2"`:

```python
# Initialize empty list for holding the tuples.
planes = []

# Go to the 'main' page.
url = "http://www.airfleets.net/recherche/supported-plane.htm"
r = requests.get(url)
soup = BeautifulSoup(r.text, 'lxml')

for td in soup.find_all('td', attrs = {'class': 'tdtexten'}):
    # Get model name and URL chunk from main page.
    model = td.a.string
    url_chunk = td.a.get('href').split('listing/')[1].split('-1')[0]

    # Go to first page for the current model.
    url = "http://www.airfleets.net/listing/%s-1.htm" % url_chunk
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'lxml')

    # Find the page count.
    a = soup.find('a', attrs = {'class': 'page2'})
    pages = int(a.string.split('/')[1])

    # Append tuple to the list.
    planes.append((model, url_chunk, pages))

print(planes)

# Output
# [('Airbus A300', 'a300', 12), ('Airbus A310', 'a310', 6), ('Airbus A318', 'a318', 2), ('Airbus A319', 'a319', 29), ('Airbus A320', 'a320', 73), ('Airbus A321', 'a321', 19), ('Airbus A330', 'a330', 22), ('Airbus A340', 'a340', 8), ('Airbus A350', 'a350', 1), ('Airbus A380', 'a380', 3), ('ATR 42/72', 'atr', 23), ('BAe 146 / Avro RJ', 'bae146', 8), ('Beech 1900D', 'beh', 9), ('Boeing 717', 'b717', 4), ('Boeing 737', 'b737', 63), ('Boeing 737 Next Gen', 'b737ng', 97), ('Boeing 747', 'b747', 30), ('Boeing 757', 'b757', 21), ('Boeing 767', 'b767', 22), ('Boeing 777', 'b777', 24), ('Boeing 787', 'b787', 3), ('Bombardier C-Series', 'csr', 1), ('Canadair Regional Jet', 'crj', 36), ('Concorde', 'ssc', 1), ('Dash 8', 'dh8', 23), ('Embraer 120 Brasilia', 'e120', 8), ('Embraer 135/145', 'e145', 24), ('Embraer 170/175', 'e170', 8), ('Embraer 190/195', 'e190', 14), ('Fokker 50', 'f50', 5), ('Fokker 70/100', 'f100', 7), ('Lockheed L-1011 TriStar', 'l10', 5), ('McDonnell Douglas DC-10', 'dc10', 9), ('McDonnell Douglas MD-11', 'md11', 4), ('McDonnell Douglas MD-80/90', 'md80', 27), ('Saab 2000', 's20', 2), ('Saab 340', 'sf3', 10), ('Sukhoi SuperJet 100', 'ssj', 1)]
```

With this list of tuples, I have something over which to iterate in order to scrape the data I want into a `.CSV` file. But first I need to look at the HTML source code for the pages that hold the information I want. Using http://www.airfleets.net/listing/a300-1.htm as an example again, the HTML for the first row in the table is:

```html
<tr class="trtab">
  <td width="17%" class=tdtexten>
    <a class="lien" title="Go to Airbus A300 MSN 1 history and information" href="../ficheapp/plane-a300-1.htm">1</a>
  </td>
  <td width="12%" class="tdtexten">300B1</td>
  <td width="22%" class="tdtexten">
    <a href="../flottecie/Airbus Industrie.htm" class=lien title="Go to Airbus Industrie fleet" >Airbus Industrie</a>
  </td>
  <td width="16%" class="tdtexten">&nbsp;  28/10/1972</td>
  <td width="13%" class="tdtexten">
    <a class="lien"  title="Go to Airbus A300 MSN F-OCAZ history and information"  href="../ficheapp/plane-a300-1.htm">F-OCAZ</a>
  </td>
  <td width="19%" class="tdtexten">Scrapped</td>
</tr>
```

The information I want for each observation (msn number, model series, airline, first flight date, registration, and status) is all within a `tr` tag with `class="trtab"`. Knowing this, I'm ready to scrape the data and write it to a `.CSV`:

```python
# Open CSV file for writing.
with open('aircraft.csv', 'wb') as file:
    writer = csv.writer(file, delimiter = ',', quotechar = '"')
    # Create header row.
    writer.writerow(["msn", "model", "series", "airline", "ff_day", "ff_month", "ff_year", "registration", "status"]) # ff = first flight

    for model, url_chunk, max_pages in planes:
        # Loop through each page for the current model.
        for page in range(1, max_pages + 1):
            url = "http://www.airfleets.net/listing/%s-%s.htm" % (url_chunk, str(page))
            r = requests.get(url)
            soup = BeautifulSoup(r.text, 'lxml')

            # Loop through each row of the table on the current page.
            for tr in soup.find_all('tr', attrs = {'class': 'trtab'}):
                try:
                    # Some models have an extra "LN" column, so I need to use different indices when going through the columns.
                    if (url_chunk == 'dc10' or url_chunk == 'md11' or url_chunk == 'md80' or url_chunk == 'bae146' or url_chunk.find('b7') != -1):
                        msn = tr.contents[1].a.string

                        if(tr.contents[5].string != None):
                            series = tr.contents[5].string.replace('\n', '').strip()
                        else:
                            series = None

                        if(tr.contents[7].a.string != None):
                            airline = unidecode(tr.contents[7].a.string)
                        else:
                            airline = None

                        if(tr.contents[9].string != None):
                            ff = tr.contents[9].string.replace(' ', '').replace('\n', '').replace(u'\xa0', '')
                        else:
                            ff = None

                        registration = tr.contents[11].a.string

                        if(tr.contents[13].string != None):
                            status = tr.contents[13].string.replace('\n', '').strip()
                        else:
                            status = None

                    # Some pages do not have an "LN" column, so I need to use different indices when going through the columns.
                    else:
                        msn = tr.contents[1].a.string

                        if(tr.contents[3].string != None):
                            series = tr.contents[3].string.replace('\n', '').strip()
                        else:
                            series = None

                        if(tr.contents[5].a.string != None):
                            airline = unidecode(tr.contents[5].a.string)
                        else:
                            airline = None

                        if(tr.contents[7].string != None):
                            ff = tr.contents[7].string.replace(' ', '').replace('\n', '').replace(u'\xa0', '')
                        else:
                            ff = None

                        registration = tr.contents[9].a.string

                        if(tr.contents[11].string != None):
                            status = tr.contents[11].string.replace('\n', '').strip()
                        else:
                            status = None

                    # Split date into day, month, year.
                    if(ff != None):
                        s = ff.split('/')
                        if (len(s) == 3):           # 'DD/MM/YYYY'
                            ff_day = int(s[0])
                            ff_month = int(s[1])
                            ff_year = int(s[2])
                        elif (len(s) == 2):         # 'MM/YYYY'
                            ff_day = None
                            ff_month = int(s[0])
                            ff_year = int(s[1])
                        elif (len(s) == 4):         # 'YYYY'
                            ff_day = None
                            ff_month = None
                            ff_year = s
                        else:                       # Empty.
                            ff_day = None
                            ff_month = None
                            ff_year = None
                    else:
                        ff_day = None
                        ff_month = None
                        ff_year = None

                    # Write data to new row in CSV.
                    writer.writerow([msn, model, series, airline, ff_day, ff_month, ff_year, registration, status])

                # Add exception for troubleshooting purposes.
                except Exception:
                    print("There was an error with a(n) %s observation on page %s." % (model, str(page)))
                    print(tr.contents)
                    pass
```

## The Result
Now I have two `.CSV` files that I will use to create a database of this information. That's covered in my next post. View snippets of the [airlines.csv](https://dl.dropboxusercontent.com/u/94782892/airline_snippet.csv) file and [aircraft.csv](https://dl.dropboxusercontent.com/u/94782892/aircraft_snippet.csv) files.