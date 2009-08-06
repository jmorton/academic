(include "math.scm")

(define >
(lambda (n m)
(cond
 ((zero? n) #f)
 ((zero? m) #t)
 (else (> (sub1 n) (sub1 m)))
)))

(define <
	(lambda (n m)
		(cond
			((zero? m) #f)
			((zero? n) #t)
			(else (< (sub1 n) (sub1 m)))
)))

(define =
	(lambda (n m)
		(cond
			((> n m) #f)
			((< n m) #f)
			(else #t)
)))

; n raised to the m_th power
(define ^	
	(lambda (n m)
		(cond
			((zero? m) 1)
			(else (times n (^ n (sub1 m))))
)))