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