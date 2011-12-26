; Test suite for our R5RS Pixley interpreter.
; Original: April 2009; Revised: November 2010
; Chris Pressey, Cat's Eye Technologies.

(load "pixley.scm")

; A list of test cases to exercise.
(define test-cases
  '(
    (   (quote hello) .
        hello
    )
    (   (car (quote (foo bar))) .
        foo
    )
    (   (cdr (quote (foo bar))) .
        (bar)
    )
    ; Because booleans don't actually have a defined representation in
    ; Pixley, the next few tests are cheating a bit...
    (   (equal? (quote a) (quote a)) .
        #t
    )
    (   (equal? (quote a) (quote b)) .
        #f
    )
    (   (equal? (quote (one (two three)))
                (cons (quote one) (quote ((two three))))) .
        #t
    )
    (   (list? (quote a)) .
        #f
    )
    (   (list? (cons (quote a) (quote ()))) .
        #t
    )
    (   (list? (cons (quote a) (quote b))) .
        #f
    )
    (   (list? (quote (a b c d e f))) .
        #t
    )
    (   (list? (equal? (quote a) (quote b)))  .
        #f
    )
    (   (list? (lambda (x y) (y x))) .
        #f
    )
    (   (list? (cdr (quote (foo)))) .
        #t
    )
    (   (let* ((a (quote hello))) a) .
        hello
    )
    (   (let* ((a (let* ((b (quote c))) b))) a) .
        c
    )
    (   (let* ((a (lambda (x y) (cons x y))))
	  (a (quote foo) (quote ()))) .
        (foo)
    )
    (   (let* ((a (quote hello)) (b (cons a (quote ())))) b) .
        (hello)
    )
    (
        (let* ((a (quote hello))) (let* ((a (quote goodbye))) a)) .
        goodbye
    )
    (   ((let*
          ((a (quote (hi)))
           (f (lambda (x) (cons x a)))) f) (quote oh)) .
        (oh hi)
    )
    (   ((lambda (a) a) (quote whee)) .
        whee
    )
    (   (let* ((true (equal? (quote a) (quote a))))
	  (cond (true (quote hi)) (else (quote lo)))) .
        hi
    )
    (   (let* ((true (equal? (quote a) (quote a)))
	       (false (equal? (quote a) (quote b))))
          (cond (false (quote hi)) (true (quote med)) (else (quote lo)))) .
        med
    )
    (   (let* ((true (equal? (quote a) (quote a)))
	       (false (equal? (quote a) (quote b))))
          (cond (false (quote hi)) (false (quote med)) (else (quote lo)))) .
        lo
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

(test)
