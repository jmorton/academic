; take a number and a list of atoms
; finds the n_th atom in the list
(define pick
	(lambda (n lat)
		(cond
			((null? lat) '())
			((zero? (sub1 n)) (car lat))
			(else (pick (sub1 n) (cdr lat)))
)))