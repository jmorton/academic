(define add1
  (lambda (n)
    (+ n 1)))

(define sub1
  (lambda (n)
    (- n 1)))

(define plus
  (lambda (m n)
    (cond
      ; terminal case
      ((zero? n) m)
      ; element, recursive case
      (else (add1 (plus m (sub1 n)))))))

; reduces m by n
(define minus
  (lambda (m n)
    (cond
      ; terminal condition m
      ((zero? n) m)
      ; subtract the natural recursion (sub1)
      (else (sub1 (minus m (sub1 n)))))))

; builds a new tup by adding together each number in tup
(define addtup
  (lambda (tup)
    (cond
      ; terminal case
      ((null? tup) 0)
      ; recursive case
      (else
        (plus (car tup)
          ; naturnal recursion
          (addtup (cdr tup)))))))

; add m together n times
(define times
  (lambda (m n)
    (cond
      ; terminal case, n is zero
      ((zero? n) 0)
      (else (plus m (times m (sub1 n)))))))
      
; builds a tup by adding together each successive atom in two tups
(define tup+
  (lambda (tup1 tup2)
    (cond
      ((and (null? tup1) (null? tup2)) '())
      ((null? tup1) (tup+ tup2 tup2))
      ((null? tup2) '())
      (else (cons (plus (car tup1) (car tup2)) (tup+ (cdr tup1) (cdr tup2)))))))

; m is less than n
(define <
	(lambda (m n)
		(cond
			((zero? m) 
				(cond
					((zero? n) #f)
					(else #t)))
			(else (< (sub1 m) (sub1 n))))))
