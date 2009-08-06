(define subst*
	(lambda (new old l)
		(cond
			((null? l) '())
			((eq? (car l) old)
				(cons new (subst* new old (cdr l))))
			(else
				(cons (car l) (subst* new old (cdr l))))
)))