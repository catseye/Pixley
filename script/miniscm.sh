#!/bin/sh

# scheme-adapter.sh wrapper to support the miniscm-0.85p1 Scheme implementation

# - miniscm          # https://github.com/catseye/minischeme

# Mini-Scheme is supported, but version 0.85p1 (a fork available
# at the above URL) is required to support the -q and -e options.
# Like Tinyscheme, Mini-Scheme insists on abbreviating quoted sexps,
# so the considerations for Tinyscheme apply for Mini-Scheme too.
# miniscm's core lacks "equal?" and "list?", so definitions for
# those are also prepended to the source we want to run.

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

if [ ! "${DEBUG}x" = "x" ]; then
    less tmpprog.scm
fi

miniscm -q -e <tmpprog.scm

rm -f tmpprog.scm
