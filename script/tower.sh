#!/bin/sh

echo -n '(define sexpfiles (quote (' >tower.scm
for SEXPFILE do
    echo -n '"'$SEXPFILE'" ' >>tower.scm
done
cat >>tower.scm <<EOF
)))

; Load an S-expression from a named file.
(define load-sexp
  (lambda (filename)
    (with-input-from-file filename (lambda () (read)))))

(define mk-interpreter
  (lambda (interpret sexp)
    (lambda (program)
      ((interpret sexp) program))))

; XXX This needs pixley.pix to evaluate to a one-argument lambda

(define tower-rec
  (lambda (filenames interpret)
    (if (null? filenames)
      '()
      (let*
	((filename (car filenames))
	 (rest     (cdr filenames))
	 (program  (load-sexp filename)))
	(if (null? rest)
	  (interpret program)
	  (tower-rec rest (mk-interpreter interpret program)))))))

(define initial-interpreter
  (lambda (program)
    (eval program (scheme-report-environment 5))))

(define tower
  (lambda (filenames)
    (tower-rec filenames initial-interpreter)))

(tower sexpfiles)
EOF

#cat tower.scm
plt-r5rs tower.scm
rm -f tower.scm
