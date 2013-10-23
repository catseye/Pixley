#!/bin/sh

# scheme-adapter.sh wrapper to support the miniscm-0.85p1 Scheme implementation

cat >init.scm <<EOF
;;; written by a.k

(define (equal? x y)
  (if (pair? x)
    (and (pair? y)
         (equal? (car x) (car y))
         (equal? (cdr x) (cdr y)))
    (and (not (pair? y))
         (eqv? x y))))

;;; written by c.p

(define (list? x) (or (eq? x '()) (and (pair? x) (list? (cdr x)))))

(define dump-sexp-tail
  (lambda (sexp)
    (cond
      ((null? sexp)
        (display ")"))
      ((pair? sexp)
        (dump-sexp (car sexp))
        (if (null? (cdr sexp))
           (display ")")
           (begin
             (display " ")
             (dump-sexp-tail (cdr sexp)))))
      (else
        (display ". ")
        (dump-sexp sexp)
        (display ")")))))

(define dump-sexp
  (lambda (sexp)
    (cond
      ((pair? sexp)
        (display "(") (dump-sexp-tail sexp))
      (else
        (display sexp)))))
EOF

echo -n '' >tmpprog.scm
if [ ! "$1"x = "/dev/nullx" ]; then
    cat $1 >>tmpprog.scm
fi
echo "(dump-sexp" >tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

miniscm -q -e <tmpprog.scm

rm -f tmpprog.scm
