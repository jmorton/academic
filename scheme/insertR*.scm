; creates a list from l by adding the new atom to
; the right of each occurrence of the old atom

(define insertR*
	(lambda (new old l)
		(cond
			((null? l) '())
			((atom? (car l))
				(cond
					((eq? (car l) old)
						(cons old (cons new (insertR* new old (cdr l)))))
					(else
						(cons (car l) (insertR* new old (cdr l))))))
			; it's a list
			(else (cons
				(insertR* new old (car l))
				(insertR* new old (cdr l))))
		)))