#!/bin/sh

# Support the miniscm-0.85p1 Scheme implementation as if it behaved like
# plt-r5rs behaves, i.e.:

#   % echo '(+ 1 2)' > program.scm
#   % miniscm.sh program.scm
#   3
#   % 

# Some caveats apply (Protip: some caveats *always* apply.)

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

echo "(display" >tmpprog.scm
cat $1 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

miniscm -q -e <tmpprog.scm

rm -f tmpprog.scm
