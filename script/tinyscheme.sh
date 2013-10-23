#!/bin/sh

# A wrapper script around tinyscheme to get it to behave more or less
# how we want.

cat >init.scm <<EOF
(define (equal? x y)
  (if (pair? x)
    (and (pair? y)
         (equal? (car x) (car y))
         (equal? (cdr x) (cdr y)))
    (and (not (pair? y))
         (eqv? x y))))
(define (list? x) (or (eq? x '()) (and (pair? x) (list? (cdr x)))))
EOF

tinyscheme $1
