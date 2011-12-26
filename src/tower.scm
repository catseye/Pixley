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

; Load an S-expression from a named file.
(define load-sexp
  (lambda (filename)
    (with-input-from-file filename (lambda () (read)))))

; The pseudocode is:
;
; pop the last file off the command line
; load the sexp from it -> current sexp
; while there are files remaining on the command line:
;     pop the last file off the command line
;     wrap the current sexp with it as an interpreter -> current sexp
; evaluate current sexp as Scheme

(define wrap-sexp
  (lambda (wrapee-sexp wrapper-sexp)
    `(let* ((interpret ,wrapper-sexp)
            (sexp      (quote ,wrapee-sexp)))
       (interpret sexp))))

(define tower-rec
  (lambda (filenames sexp)
    (if (null? filenames)
      (eval sexp (scheme-report-environment 5))
      (let* ((filename (car filenames))
             (rest     (cdr filenames))
             (sexp     (wrap-sexp sexp (load-sexp filename))))
          (tower-rec rest sexp)))))
      
(define tower
  (lambda (filenames)
    (let* ((filenames (reverse filenames)))
      (if (null? filenames)
        '()
        (let* ((filename (car filenames))
               (rest     (cdr filenames))
               (sexp     (load-sexp filename)))
          (tower-rec rest sexp))))))
