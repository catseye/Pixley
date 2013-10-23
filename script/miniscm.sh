#!/bin/sh

# scheme-adapter.sh wrapper to support the miniscm-0.85p1 Scheme implementation

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

echo -n '' >tmpprog.scm
if [ ! "$1"x = "/dev/nullx" ]; then
    cat $1 >>tmpprog.scm
fi
echo "(display" >tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

miniscm -q -e <tmpprog.scm

rm -f tmpprog.scm
