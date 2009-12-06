(include "math.scm")

; removes all the nums from a lat
(define no-nums
	(lambda (lat)
		(cond
			((null? lat) '())
			(else
				(cond
					((number? (car lat)) (no-nums (cdr lat)))
					(else (cons (car lat) (no-nums (cdr lat))))))
)))

(define all-nums
	(lambda (lat)
		(cond
			((null? lat) '())
			(else
				(cond
					((number? (car lat)) (cons (car lat) (all-nums (cdr lat))))
					(else (all-nums (cdr lat)))))
)))

; the two arguments are the same atom
(define eqan?
	(lambda (a1 a2)
		(cond
			((and (number? a1) (number? a2)) (= a1 a2))
			(else (eq? a1 a2))
)))

(define occur
	(lambda (a lat)
		(cond
			((null? lat) 0)
			(else 
				(cond
					((eq? (car lat) a) (add1 (occur a (cdr lat))))
					(else (occur a (cdr lat)))))
)))

(define one?
	(lambda (n)
		(= n 1)))
		
(define numbered?
	(lambda (exp)
		(cond
			((atom? exp) #t) ; it's a number
			(()) ; it's an operator
			() ; it's an expression
			() ; it's none of those things
)))