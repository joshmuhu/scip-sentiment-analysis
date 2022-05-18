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