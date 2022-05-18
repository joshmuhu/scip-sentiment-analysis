# scip-sentiment-analysis
An extra racket abstraction file on top of the data-science package by Nicholas M. Van Horn specifically for tweets sentiment analysis

## Table of contents
1. Installation
2. Reading Json file
3. Getting tweets by source
4. Timestamps by source
5. Timestamp line graph by source
6. Tweets classification by tweet content
7. Tweets classification by image by source
8. Sentiments by category
9. Histogram plot most common words
10. Classification by positive and negative words
11. Negative- positive sentiment graph

## Installation
1. Assumption: you have racket installed
2. git clone the repository https://github.com/joshmuhu/scip-sentiment-analysis.git
3. install the following package raco pkg install https://github.com/n3mo/data-science.git
4. run the testing.rkt

## Reading Json file
The read_json function takes in the path of the json file. It an addition to the existing read_csv function
> (define tweets (read_json "temp.json"))

## Getting tweets by source
This function enables one to extract tweets by phone source, either android, iphone etc ........
> (define android (tweet-by-source "Android" t))

## Getting tweets by timestamps
retrieves data formatted in this format "~a ~b ~d ~H:~M:~S ~z ~Y"
> (define android-timestamp (timestamp-by-type-new "Android" t))
Filling in the missing times to cater for 24hr
> (define a-time (binned-times-per-category "Android" t))

## Timestamp line graph by source
An hourly graph showing variations between the data sources passed to it
a-time: takes in android time series, i-time: takes in iphone time series
> (line-graph-for-hour-comparison a-time i-time)


