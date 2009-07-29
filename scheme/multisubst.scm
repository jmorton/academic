(define multisubst
	(lambda (new old lat)
		(cond
			; terminal condition
			((null? lat) '())
			(else
				(cond
					; recursive case
					((eq? (car lat) old) (cons new (multisubst new old (cdr lat))))
					(else (cons (car lat) (multisubst new old (cdr lat)))))))))

(print (multisubst 'x 'd '(d a b d a b a b c)))
