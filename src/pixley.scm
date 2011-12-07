; A Pixley interpreter, implemented in R5RS Scheme.
; April 2009, Chris Pressey, Cat's Eye Technologies.

; This is really just a Scheme wrapper for the Pixley interpreter
; written in Pixley.  Because Pixley is a strict subset of R5RS Scheme,
; this is scarcely an astounding feat.

; Load an S-expression from a named file.
(define load-sexp
  (lambda (filename)
    (display "loading ") (display filename) (display "...") (newline)
    (with-input-from-file filename (lambda () (read)))))

; Return an S-expression representing a Pixley interpreter.
; For convenience, it is loaded from its file.
(define pixley-interpreter-sexp
  (load-sexp "pixley.pix"))

; Return a Scheme procedure value denoting an executable Pixley interpreter,
(define pixley-interpreter
  (eval pixley-interpreter-sexp (scheme-report-environment 5)))

; Interpret a given Pixley program represented as an S-expression.
(define interpret-pixley
  (lambda (program-sexp)
    (pixley-interpreter pixley-interpreter program-sexp '())))

; Interpret a given Pixley program contained in a specified named file.
(define interpret-pixley-file
  (lambda (filename)
    (interpret-pixley (load-sexp filename))))

; There's something just plain unwholesome about quasiquote, don't you think?
; Sure it's useful, but it makes your beautiful Scheme program start to look
; something awful, with little hairs and the like strewn about.  Ugly, what.
; Sometimes downright Perlish.

; To remedy this, I have devised a cute little hygienic macro called
; 'let-symbol' which does essentially the same task, but (IMO) in a cleaner way.
; let-symbol, like let, takes a set of bindings.  Also like let, it evaluates the
; values in those bindings exactly once.  Unlike let, it binds those values to
; symbols.  The body of the let-symbol is interpreted as a literal s-expression,
; except that every place one of the bound symbols is encountered, the
; evaluated value that it is bound to is inserted instead.

; Our replacement for quasiquote.
(define-syntax let-symbol
  (syntax-rules ()
    ((let-symbol bindings body)
      (let-symbol bindings () body))
    ((let-symbol ((key val) . rest) defn body)
      (let ((key val)) (let-symbol rest (key . defn) body)))
    ((let-symbol () defn (a . b))
      (cons (let-symbol () defn a) (let-symbol () defn b)))
    ((let-symbol () (key . rest) sym)
      (let-syntax
        ((is-bound
          (syntax-rules (key)
            ((is-bound key) sym)
            ((is-bound _)   (let-symbol () rest sym)))))
        (is-bound sym)))
    ((let-symbol () () sym)
      (quote sym))))

; A version of let-symbol which evaluates the symbol-bound expressions
; lazily, at the point when they are inserted in the final S-expression.
; Included for the sake of comparison only.
(define-syntax let-symbol-lazy
  (syntax-rules ()
    ((let-symbol env ())
      ())
    ((let-symbol env (a . b))
      (cons (let-symbol env a) (let-symbol env b)))
    ((let-symbol () sym)
      (quote sym))
    ((let-symbol ((key val) . rest) sym)
      (let-syntax
        ((is-key
          (syntax-rules (key)
            ((is-key key) val)
            ((is-key _)   (let-symbol rest sym)))))
        (is-key sym)))))

; Create a Pixley program which applies the Pixley interpreter (written in Pixley)
; to the given S-expression (a Pixley program).
(define wrap-pixley-interpreter
  (lambda (sexp)
    (let-symbol ((interpreter-val (load-sexp "pixley.pix"))
                 (sexp-val        sexp))
      (let* ((interpreter interpreter-val)
             (sexp        (quote sexp-val)))
        (interpreter interpreter sexp '())))))

; Here's the quasiquote version of the above, just for comparison.
(define wrap-pixley-interpreter-quasiquote
  (lambda (sexp)
    (let* ((interpreter (load-sexp "pixley.pix")))
      `(let* ((interpreter ,interpreter)
              (sexp (quote ,sexp)))
         (interpreter interpreter sexp '())))))

; Create an n-level Pixley program that applies n Pixley interpreters to the
; given S-expression.
(define wrap-pixley-interpreter-nth
  (lambda (degree sexp)
    (cond
      ((zero? degree)
        sexp)
      (else
        (wrap-pixley-interpreter-nth (- degree 1) (wrap-pixley-interpreter sexp))))))

; A list of test cases to exercise.
(define test-cases
  '(
    (   (let* ((a (quote hello))) a) .
        hello
    )
    (   (let* ((a (lambda (x y) (cons x y)))) (a (quote foo) (quote ()))) .
        (foo)
    )
  )
)

; Our test harness.
(define run-tests
  (lambda (degree all-tests tests)
    (cond
      ((null? tests)
        (run-tests (+ 1 degree) all-tests all-tests))
      (else
        (let* ((test-prog   (caar tests))
               (expected    (cdar tests))
               (rest        (cdr tests))
               (sexp        (wrap-pixley-interpreter-nth degree test-prog))
               (result      (interpret-pixley sexp)))
          (begin
            (display "Degree: ") (display degree) (display " ")
            (display test-prog) (display "...")
            (cond
              ((equal? result expected)
                (begin (display "PASS") (newline)
                  (run-tests degree all-tests rest)))
              (else
                (begin (display "FAIL") (newline)
                  (display "Expected: ") (display expected) (newline)
                  (display "Actual: ") (display result) (newline))))))))))

; Top-level driver for the test harness.
(define test
  (lambda ()
    (run-tests 0 test-cases test-cases)))
