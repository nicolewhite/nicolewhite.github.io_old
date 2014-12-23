#!/bin/bash
./r2jekyll.R $1
cp ../_drafts/"{{ site.url }}"/examples/* ../examples
rm -r ../_drafts/"{{ site.url }}"
cd ..
jekyll serve --config _config.yml,config.preview.yml &
sleep 3
open "http://localhost:4000"