#!/bin/bash

if [ -z "$1" ]
then
    echo "No argument supplied"
fi

if [ "$1" == "help" ]
then
    echo "runserver : run localserver on 4000 port"
elif [ "$1" == "runserver" ]
then
	# 사용을 위해 
	# gem install jekyll jekyll-feed jekyll-sitemap 
	# 필요함
    jekyll serve
else
    echo "Unknown argument"
fi
