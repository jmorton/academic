(define subst*
	(lambda (new old l)
		(cond
			((null? l) '())
			((atom? (car l))
				(cond
					((eq? (car l) old)
						(cons
							new
							(subst* new old (cdr l))))
				(else
					(cons
						(car l)
						(subst* new old (cdr l))))))
			(else ; it's a list
				(cons
					(subst* new old (car l))
					(subst* new old (cdr l))))
)))