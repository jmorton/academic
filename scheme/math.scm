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
