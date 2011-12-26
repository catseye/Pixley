; Statistics on our meta-circular Pixley interpreter.
; November 2010, Chris Pressey, Cat's Eye Technologies.

; Load an S-expression from a named file.
(define load-sexp
  (lambda (filename)
    (with-input-from-file filename (lambda () (read)))))

(define count-cons-cells
  (lambda (sexp)
    (cond
      ((null? sexp)
        0)
      ((list? sexp)
        (+ 1 (count-cons-cells (car sexp)) (count-cons-cells (cdr sexp))))
      (else
        0))))

(define count-symbol-instances
  (lambda (sexp)
    (cond
      ((null? sexp)
        0)
      ((list? sexp)
        (+ (count-symbol-instances (car sexp))
	   (count-symbol-instances (cdr sexp))))
      ((symbol? sexp)
        1)
      (else
        0))))

(define collect-unique-symbols
  (lambda (sexp table)
    (cond
      ((null? sexp)
        table)
      ((list? sexp)
        (let* ((new-table (collect-unique-symbols (car sexp) table)))
	  (collect-unique-symbols (cdr sexp) new-table)))
      ((symbol? sexp)
        (if (memq sexp table)
	    table
	    (cons sexp table)))
      (else
        table))))

(define report
  (lambda (filename)
    (display "File: ") (display filename) (newline)
    (let ((sexp (load-sexp filename)))
      (display "Cons cells: ") (display (count-cons-cells sexp)) (newline)
      (display "Symbol instances: ") (display (count-symbol-instances sexp)) (newline)
      (display "Unique symbols: ")
      (let* ((unique-symbols (collect-unique-symbols sexp '())))
        (display (length unique-symbols))
        (display " ")
        (display unique-symbols)
        (newline)))))

(report "pixley.pix")

