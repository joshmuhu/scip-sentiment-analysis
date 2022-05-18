#lang racket
(require data-science)
(require plot)
(require math)
(require json)
(require net/url)
(require racket/date)
(require (only-in srfi/19 string->date))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;abstraction to refer to call with input ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-tweets file-name)
  (call-with-input-file file-name read-json)
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;abstraction to read_json file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (read_json file-name)
  (let ([mn (get-tweets file-name)])
    (let ([tmp (map (λ (x) (list (hash-ref x 'text) (hash-ref x 'source)
                                 (hash-ref x 'created_at) (hash-ref x 'place_id) (hash-ref x 'retweet_count))) mn)])
      (filter (λ (x) (not (string-prefix? (first x) "RT"))) tmp))
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;abstraction to get tweets by source ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (tweet-by-source source-name data)
  (filter (λ (x) (string=? (second x) source-name))(map (λ (x) (list (first x)
                    (cond [(string-contains? (second x) source-name) source-name][else "other"])
                     ))
       data)))
;;;testing


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; converting our date to time stamp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (convert-timestamp str) ;Thu Sep 28 11:01:16 +0000 2017 2022-02-26T04:29:27.000Z
  (string->date str "~a ~b ~d ~H:~M:~S ~z ~Y")
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Timestamps by source ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (timestamp-by-type-new source-name data) 
  (map (λ (x) (list (third x)
                    (cond [(string-contains? (second x) source-name) source-name][else "other"])
                    ))
       data))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; counting timestamps by bins ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (bin-timestamps timestamps)
  (sorted-counts
     (map (λ (x) (date-hour (convert-timestamp x))) timestamps)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; binned times per category ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (binned-times-per-category category data)
  (bin-timestamps ($ (subset (timestamp-by-type-new category data) 1 (λ (x) (string=? x category))) 0))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; fillking missing bins by parameter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (fill-missing-bins lst bins)
  (define (get-count lst val)
    (let ([count (filter (λ (x) (equal? (first x) val)) lst)])
      (if (null? count) (list val 0) (first count))))
  (map (λ (bin) (get-count lst bin))
       bins))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Convert UTC time to EST ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (time-EST lst)
  (map list
       ($ lst 0)
       (append (drop ($ lst 1) 4) (take ($ lst 1) 4))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Convert bin counts to percentages ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (count->percent lst)
  (let ([n (sum ($ lst 1))])
    (if (> n 0)
    (map list
         ($ lst 0)
         (map (λ (x) (* 100 (/ x n))) ($ lst 1)))
(map list
         ($ lst 0)
         (map (λ (x) (* 100 (/ x 1))) ($ lst 1)))

    )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; comparisonal line graph on two variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; What time of day do the different devices tend to tweet?
(define (line-graph-for-hour-comparison category-one category-two)
(let ([a-data (count->percent (time-EST (fill-missing-bins category-one (range 24))))]
      [i-data (count->percent (time-EST (fill-missing-bins category-two (range 24))))])
  (parameterize ([plot-legend-anchor 'top-right]
                 [plot-width 600])
      (plot (list
             (tick-grid)
             (lines a-data
                    #:color "OrangeRed"
                    #:width 2
                    #:label "Android")
             (lines i-data
                    #:color "LightSeaGreen"
                    #:width 2
                   #:label "iPhone")
             )
            #:x-label "Hour of day (EST)"
            #:y-label "% of tweets")))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; classify tweets by text content ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (tweets-classification-by-image data)
  (let ([pics (map (λ (x)
                     (if (string-contains? x "t.co")
                         "Picture/Link"
                         "No picture/link"))
                   ($ data 0))])
    (let-values ([(label n) (count-samples pics)])
      (map list label n))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; histogram per category ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Restructure the data for our histogram below

;;;;;;;;;;;;;;;;;;;;;;;;;;; GET PICS
(define (get-pics data-one data-two cate-one cate-two)
  (list `("Android" ,(second (second data-one)))`("iPhone" ,(second (second data-two)))))
;;;;;;;;;;;;;;;;;;;;;;;;; GET NON PICS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-no-pics data-one data-two category-one category-two)
  (list `(cate-one ,(second (first data-one))) `(cate-two ,(second (first data-two)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;HISTOGRAM BY TWEETS IMAGE IN CATEGORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (histogram-tweets-by-image-category data-one data-two category-one category-two)
  (
   let ([pics (get-pics data-one data-two category-one category-two)]
        [no-pics (get-no-pics data-one data-two category-one category-two)])
    (parameterize ([plot-legend-anchor 'top-right])
      (plot (list (discrete-histogram no-pics
                                      #:label "No picture/link"
                                      #:skip 2.5
                                      #:x-min 0
                                      #:color "OrangeRed"
                                      #:line-color "OrangeRed")
                  (discrete-histogram pics
                                      #:label "Picture/link"
                                      #:skip 2.5
                                      #:x-min 1
                                      #:color "LightSeaGreen"
                                      #:line-color "LightSeaGreen"))
            #:y-max 3000
            #:x-label ""
            #:y-label "Number of tweets"))
    )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;sentiments per category ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-sentiments-by-category dat [lexicon 'nrc])
  (let ([data ($ dat 0)])
       (let([joined-string (string-join data " ")])
        (let ([words (document->tokens joined-string #:sort? #t)])
        (list->sentiment words #:lexicon lexicon)
         ))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; most common words ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-sentiments-histogram dat)
  (let ([sentiment (get-sentiments-by-category dat 'nrc)])
        (let ([counts (aggregate sum ($ sentiment 'sentiment) ($ sentiment 'freq))])
        
    (parameterize ((plot-width 800))
      (plot (list
             (tick-grid)
             (discrete-histogram
              (sort counts (λ (x y) (> (second x) (second y))))
              #:color "MediumSlateBlue"
              #:line-color "MediumSlateBlue"))
            #:x-label "Affective Label"
            #:y-label "Frequency"))
    ))
  )
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; positive to negative words ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (positive-negative-words data lexicon) (get-sentiments-by-category data lexicon) )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; plotting negative positive sentiment ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (plot-negative-positive data lexicon)
  (let ([sentiment (positive-negative-words data lexicon)])
  (parameterize ([plot-height 200])
  (plot (discrete-histogram
	 (aggregate sum ($ sentiment 'sentiment) ($ sentiment 'freq))
	 #:y-min 0
	 #:y-max 5000
	 #:invert? #t
	 #:color "MediumOrchid"
	 #:line-color "MediumOrchid")
	#:x-label "Frequency"
	#:y-label "Sentiment Polarity"))

))

