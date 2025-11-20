;; ---------------------------------------------------------
;; Pair Matching Game (Clarity)
;; Simple 1v1 pairing system based on a given tag.
;; - First player joins a tag -> becomes waiting.
;; - Second player joins same tag -> instantly matched.
;; - Store all matches with incremental match ID.
;; - Simple, readable, Clarinet-friendly.
;; ---------------------------------------------------------

(define-data-var match-count uint u0)

;; waiting players per tag
(define-map waiting
  {tag: (string-utf8 32)}
  {who: principal})

;; stored matches
(define-map matches
  {id: uint}
  {a: principal, b: principal, tag: (string-utf8 32), created: uint}
)

;; error codes
;; u300 = already waiting for same tag
;; u301 = not waiting / unauthorized leave
;; u303 = match not found

;; ---------------------------------------------------------
;; READ-ONLY HELPERS
;; ---------------------------------------------------------

(define-read-only (get-waiting (tag (string-utf8 32)))
  (match (map-get? waiting (tuple (tag tag)))
    entry (ok (get who entry))
    (ok tx-sender)
  )
)

(define-read-only (get-match (id uint))
  (match (map-get? matches (tuple (id id)))
    m (ok m)
    (err u303)
  )
)

(define-read-only (get-match-count)
  (ok (var-get match-count))
)

;; ---------------------------------------------------------
;; PRIVATE INTERNAL
;; ---------------------------------------------------------

(define-private (create-match (p1 principal) (p2 principal) (tag (string-utf8 32)))
  (let (
        (mid (var-get match-count))
        (blk stacks-block-height)
       )
    (begin
      (map-set matches
        (tuple (id mid))
        (tuple (a p1) (b p2) (tag tag) (created blk))
      )
      (var-set match-count (+ mid u1))
      mid
    )
  )
)

;; ---------------------------------------------------------
;; PUBLIC FUNCTIONS
;; ---------------------------------------------------------

;; JOIN matchmaking for a tag
(define-public (join (tag (string-utf8 32)))
  (let ((player tx-sender))
    (begin
      ;; check if someone is waiting already
      (match (map-get? waiting (tuple (tag tag)))
        entry
        (let ((waiting-who (get who entry)))
          (begin
            (if (is-eq waiting-who player)
                (err u300) ;; can't wait twice
                (let ((mid (create-match waiting-who player tag)))
                  (map-delete waiting (tuple (tag tag)))
                  (ok mid)
                )
            )
          )
        )
        ;; none case: nobody waiting -> player becomes the waiting one
        (begin
          (map-set waiting (tuple (tag tag)) (tuple (who player)))
          (ok u0)
        )
      )
    )
  )
)

;; LEAVE matchmaking if you are the waiting player
;; <CHANGE> Fixed unwrap! syntax - changed from 4 arguments to proper match expression
(define-public (leave (tag (string-utf8 32)))
  (let ((player tx-sender))
    (match (map-get? waiting (tuple (tag tag)))
      entry
      (let ((waiting-who (get who entry)))
        (if (is-eq waiting-who player)
            (begin
              (map-delete waiting (tuple (tag tag)))
              (ok true)
            )
            (err u301)
        )
      )
      (err u301)
    )
  )
)