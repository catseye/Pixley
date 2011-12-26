; A Pixley interpreter harness, implemented in R5RS Scheme.
; Original: April 2009, Chris Pressey, Cat's Eye Technologies.

; This is really just a Scheme wrapper for the Pixley interpreter
; written in Pixley.  Because Pixley is a strict subset of R5RS Scheme,
; this is scarcely an astounding feat.

; Load an S-expression from a named file.
(define load-sexp
  (lambda (filename)
    ; (display "loading ") (display filename) (display "...") (newline)
    (with-input-from-file filename (lambda () (read)))))

; Return an S-expression representing a Pixley interpreter.
; For convenience, it is loaded from its file.
(define pixley-interpreter-sexp
  (load-sexp "pixley.pix"))

; Return a Scheme procedure value denoting an executable Pixley interpreter.
(define interpret-pixley
  (eval pixley-interpreter-sexp (scheme-report-environment 5)))

; Interpret a given Pixley program contained in a specified named file.
(define interpret-pixley-file
  (lambda (filename)
    (interpret-pixley (load-sexp filename))))

; Create a Pixley program which applies the Pixley interpreter (written in
; Pixley) to the given S-expression (a Pixley program).
(define wrap-pixley-interpreter
  (lambda (sexp)
    `(let* ((interpret ,pixley-interpreter-sexp)
            (sexp      (quote ,sexp)))
       (interpret sexp))))

; Create an n-level Pixley program that applies n Pixley interpreters to the
; given S-expression.
(define wrap-pixley-interpreter-nth
  (lambda (degree sexp)
    (cond
      ((zero? degree)
        sexp)
      (else
        (wrap-pixley-interpreter-nth (- degree 1)
                                     (wrap-pixley-interpreter sexp))))))
