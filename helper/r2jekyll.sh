#!/bin/bash
./r2jekyll.R $1 $2
cd ..
if [ "$1" = "preview"]
then
	jekyll serve --drafts &
	sleep 3 
	open "http://localhost:4000"
elif [ "$1" = "publish"]
then
	jekyll serve &
	sleep 3 
	open "http://localhost:4000"
else
	echo "Your syntax is wrong."
fi