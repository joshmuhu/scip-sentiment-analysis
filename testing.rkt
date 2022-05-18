#lang racket
(require racket/include)
(include "main.rkt")

;reading the json file
(define t (read_json "temp.json"))
;getting data by source
;using android or iphone example
(define android (tweet-by-source "Android" t))
(define iphone (tweet-by-source "iPhone" t))

;;;getting by timestamps
(define android-timestamp (timestamp-by-type-new "Android" t))
(define iphone-timestamp (timestamp-by-type-new "iPhone" t))

;;;filling all the bins
(define a-time (binned-times-per-category "Android" t))
(define i-time (binned-times-per-category "iPhone" t))

;;;line graph of android against iphone users
(line-graph-for-hour-comparison a-time i-time)

;;;getting tweets that have images or not
(define android-pics (tweets-classification-by-image android))
(define iphone-pics (tweets-classification-by-image iphone))

;;;drawring their graph
(histogram-tweets-by-image-category android-pics iphone-pics "Android" "Iphone")

;;;;;; tweets by source
(get-sentiments-histogram android "Tweets from Android")
(get-sentiments-histogram iphone "Tweets from Iphone")

;;;;; plotting negative and positive sentiments
(plot-negative-positive android 'bing)
