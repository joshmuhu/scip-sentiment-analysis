# scip-sentiment-analysis
An extra racket abstraction file on top of the data-science package by Nicholas M. Van Horn specifically for tweets sentiment analysis

## Table of contents
1. Installation
2. Reading Json file
3. Getting tweets by source
4. Timestamps by source
5. Timestamp line graph by source
6. Tweets classification by tweet content
7. Tweets classification by image by source (Histogram)
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

![Time Series now changed](/a-time.png)

## Tweets classification by tweet content
Enables us to get tweets classified by containing image or not
> (define android-pics (tweets-classification-by-image android))

## Tweets classification by image by source (histogram)
The above classified tweets as containing image or not per source can be visualized using this function
>(histogram-tweets-by-image-category android-pics iphone-pics "Android" "Iphone")

![Time Series now changed](/image-no-image.png)

## Sentiments by category
Get sentiments of tweets by source category. lexicon can be any 'nrc, 'bing etc
> (get-sentiments-by-category data lexicon)

## Histogram plot most common words
Drawing a histogram for the sentiments of the category passed to the function
> (get-sentiments-histogram android "Tweets from Android")

Android Tweets sentiment

![Time Series now changed](/tweets-android.png)

Iphone Tweets sentiment

![Time Series now changed](/iphone-tweets.png)

## Classification by positive and negative words
using the different lexicons we can classify into positive or negative
> (positive-negative-words data lexicon)

## Negative- positive sentiment graph
Bar graph for negative positive sentiment
> (plot-negative-positive android 'bing)

![Time Series now changed](/negative-positive.png)
