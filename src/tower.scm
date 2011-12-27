; A driver for running interpreters (on interpreters...) on Scheme.

; This is a sexp-based tower implementation.  This is like what is
; done in pixley.scm; the program to be run is wrapped in zero or
; more interpreters (as S-expressions), and then the whole thing is
; evaluated as a Scheme program.

; It is also possible to write a lambda-based tower implementation,
; where we load the sexps top-down, creating a function from each
; of them as we go.
; However, this runs into the problem that Pixley functions do not
; have the same representation, in Scheme, as Scheme procedures.
; If you're interested, you can look at earlier revisions of this
; file in the repository -- but you are probably not that interested.

; The pseudocode is:
;
; pop the top sexp off the tower -> current sexp
; while there are sexps remaining on the tower:
;     pop the top sexp off the tower
;     wrap the current sexp with it as an interpreter -> current sexp
; you now have a sexp that you can evaluate as Scheme

(define subst
  (lambda (sexp src dest)
    (cond
      ((equal? sexp src)
        dest)
      ((null? sexp)
        '())
      ((list? sexp)
        (cons (subst (car sexp) src dest) (subst (cdr sexp) src dest)))
      (else
        sexp))))

(define wrap-sexp
  (lambda (wrapee-sexp wrapper-sexp)
    (subst
      (subst (quote (let* ((interpret wrapper-sexp)
                           (sexp      (quote wrapee-sexp)))
                      (interpret sexp)))
             (quote wrapper-sexp) wrapper-sexp)
      (quote wrapee-sexp) wrapee-sexp)))

(define tower-rec
  (lambda (sexp-tower sexp)
    (if (null? sexp-tower)
      sexp
      (let* ((interpreter-sexp (car sexp-tower))
             (rest             (cdr sexp-tower)))
        (tower-rec rest (wrap-sexp sexp interpreter-sexp))))))

(define make-tower
  (lambda (sexp-tower)
    (let* ((sexp-tower (reverse sexp-tower)))
      (if (null? sexp-tower)
        '()
        (let* ((sexp (car sexp-tower))
               (rest (cdr sexp-tower)))
          (tower-rec rest sexp))))))
