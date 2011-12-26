; REPL for our R5RS Pixley interpreter.
; November 2010, Chris Pressey, Cat's Eye Technologies.

(load "pixley.scm")

; A Pixley Read-Evaluate-Print Loop (REPL) with which one can experiment
; with our implementation of the Pixley language.
(define repl
  (lambda ()
    (begin
      (display "pixley> ")
      (let* ((line   (read))
             (result (interpret-pixley line)))
	(display result)
	(newline)
	(repl)))))

(repl)
