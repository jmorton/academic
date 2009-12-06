; remove all occurences of a from l
(define rember*
	(lambda (a l)
		(cond
			((null? l) '())
			((atom? (car l))
				(cond
					((eq? (car l) a) (rember* a (cdr l)))
					(else (cons (car l) (rember* a (cdr l))))))
			; it's a list
			(else (cons
				(rember* a (car l))
				(rember* a (cdr l))))
)))