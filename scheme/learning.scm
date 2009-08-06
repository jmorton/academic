(define lat?
  (lambda (l)
    (cond
      ((null? l) #t)
      ((atom? (car l)) (lat? (cdr l)))
      (else #f)
    )
  )
)

(define member?
  (lambda (a l)
    (cond
      ((null? l) #f)
      (else (or (eq? a (car l)) (member? a (cdr l))))
    )))

; remove the first occurrence of an atom from the list
(define rember
  (lambda (a lat)
    (cond
      ((null? lat) '())
      ((eq? (car lat) a) (cdr lat))
      (else (cons (car lat) (rember a (cdr lat)))))
    )
  )

; takes a lat and makes a new lat in reverse order of the old lat 
; by consing the reverse of the remainder of the list with the start  
(define my_reverse
  (lambda (lat)
    (cond
      ((null? lat) '())
      (else (cons ((my_reverse (cdr lat)) (car lat))))
      )))
      
; firsts takes a list of lists and makes a new list using
; the first S-expression in each list
(define -first
  (lambda (lats)
    (cond
      ((null? lats) '())
      (else (  cons  (car (car lats))  (-first (cdr lats))  ))
      )))

(define insert_r
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      (else
        (cond
          ((eq? (car lat) old)
            (cons old (cons new (cdr lat))))
          (else
            (cons old (insert_r new old lat)))
          )))))
      
(define insert_l
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? (car lat) old) (cons new lat))
      (else (cons (car lat) (insert_l new old (cdr lat)))))))
  
(define subst
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? (car lat) old) (cons new (cdr lat)))
      (else (cons (car lat) (subst new old (cdr lat)))))))

(define multirember
  (lambda (a lat)
    (cond
      ((null? lat) '())
      ((eq? (car lat) a) (multirember a (cdr lat)))
      (else (cons (car lat) (multirember a (cdr lat)))))))

