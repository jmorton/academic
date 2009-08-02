(define add1
  (lambda (n)
    (+ n 1)))

(print (add1 1))

(define sub1
  (lambda (n)
    (- n 1)))

(print (sub1 1))

(define plus
  (lambda (m n)
    (cond
      ; terminal case
      ((zero? n) m)
      ; element, recursive case
      (else (add1 (plus m (sub1 n)))))))
      
(print (plus 7 11))

; reduces m by n
(define minus
  (lambda (m n)
    (cond
      ; terminal condition m
      ((zero? n) m)
      ; subtract the natural recursion (sub1)
      (else (sub1 (minus m (sub1 n)))))))

(print (minus 1 1))
(print (minus 5 1))
(print (minus 1 2))

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

(print (addtup '(1 2 3)))
(print (addtup '(1 5 9)))

; add m together n times
(define times
  (lambda (m n)
    (cond
      ; terminal case, n is zero
      ((zero? n) 0)
      (else (plus m (times m (sub1 n)))))))
      
(print (times 1 1))
(print (times 1 2))
(print (times 1 3))
(print (times 2 2))
(print (times 3 3))
(print (times 7 11))

; builds a tup by adding together each successive atom in two tups
(define tup+
  (lambda (tup1 tup2)
    (cond
      ((and (null? tup1) (null? tup2)) '())
      ((null? tup1) (tup+ tup2 tup2))
      ((null? tup2) '())
      (else (cons (plus (car tup1) (car tup2)) (tup+ (cdr tup1) (cdr tup2)))))))

(print (tup+ '(1 1 1) '(1 2 3)))
(print (tup+ '(1 1 1) '(1 2 3 4)))

; m is less than n
(define <
	(lambda (m n)
		(cond
			((zero? m) 
				(cond
					((zero? n) #f)
					(else #t)))
			(else (< (sub1 m) (sub1 n))))))
		
(print (< 1 2))
(print (< 1 1))
(print (< 2 1))
