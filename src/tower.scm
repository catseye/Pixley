; Load an S-expression from a named file.
(define load-sexp
  (lambda (filename)
    (with-input-from-file filename (lambda () (read)))))

; Listen carefully!

; If you evaluate a one-argument lambda expression with a Scheme
; interpreter, you get a normal, one-argument procedure value.
; ("Scheme procedure")

; Initially, the Scheme interpreter in use is a Scheme procedure.

; If you evaluate a one-argument lambda expression with a Pixley
; interpreter, you get a function value which takes a list which
; should contain exactly one value, which is used as the argument.
; ("Pixley procedure")

; Therefore, you need to include some pragmas in the list of filenames
; you pass to tower.  For example, if you say:

;     (tower "simple.pix")

; ...you get a normal sexp passed as the only argument to the Scheme
; procedure.  And if you say:

;     (tower "reverse.pix" "some-sexp.sexp")

; ...you get a normal sexp passed as the only argument to the Scheme
; procedure, yielding another Scheme procedure; the last sexp is
; passed as normal to it.

; And, when you say

;     (tower "pixley.pix")

; ...the result of this is a Scheme procedure (because it was
; interpreted in Scheme.)  So you can say:

;     (tower "pixley.pix" "simple.pix")

; ...BUT.  Once you say

;     (tower "pixley.pix" "pixley.pix")

; ...the result of THAT will be a Pixley procedure.  So you CAN'T
; further say

;     (tower "pixley.pix" "pixley.pix" "simple.pix")

; Instead, you have to wrap the Pixley procedure in a Scheme procedure,
; which can be done with the special name "+":

;     (tower "pixley.pix" "pixley.pix" "+" "simple.pix")

; It gets worse, the higher you go:

;     (tower "pixley.pix" "pixley.pix" "+" "pixley.pix" "+" "+" "simple.pix")

; I wish I could say exactly why!

; script/tower.sh src/pixley.pix src/pixley.pix + eg/reverse.pix + + eg/some-list.sexp 
; script/tower.sh src/pixley.pix eg/reverse.pix + eg/some-list.sexp

(define wrap-scheme
  (lambda (pixley-procedure)
    (lambda (arg) (pixley-procedure (list arg)))))

; The pseudocode is:
;
; set the current interpreter to the Scheme interpreter
; while there are files remaining on the command line:
;     get the next file off the command line
;     load the sexp from it
;     interpret the sexp with the current interpreter to get a result
;     are there any more files on the command line?
;         yes: set the current interpreter to the result, and loop
;         no: display the result and stop

(define tower-rec
  (lambda (filenames interpret)
    (if (null? filenames)
      '()
      (let*
	((filename (car filenames))
	 (rest     (cdr filenames)))
        (if (equal? filename "+")
          (tower-rec rest (wrap-scheme interpret))
          (let*
	    ((program  (load-sexp filename))
             (result   (interpret program)))
            (if (null? rest)
              result
              (tower-rec rest result))))))))

(define initial-interpreter
  (lambda (program)
    (eval program (scheme-report-environment 5))))

(define tower
  (lambda (filenames)
    (tower-rec filenames initial-interpreter)))
