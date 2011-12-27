#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation.

if [ "${SCHEME}x" = "x" ]; then
    SCHEME=plt-r5rs
fi

if [ "${USE_EVAL}x" = "x" ]; then
    USE_EVAL=yes
fi

if [ "${SCHEME}" = "miniscm" -o "${SCHEME}" = "tinyscheme" ]; then
    USE_EVAL=no
fi

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`

cd ${SCRIPTDIR}/..
echo -n '' >init.scm
if [ "$SCHEME" = "miniscm" ]; then
    cat >prelude.scm <<EOF
;;;;; following part is written by a.k

;;;;    equal?
(define (equal? x y)
  (if (pair? x)
    (and (pair? y)
         (equal? (car x) (car y))
         (equal? (cdr x) (cdr y)))
    (and (not (pair? y))
         (eqv? x y))))

;;;;; following part is written by c.p.

(define (list? x) (or (eq? x '()) (and (pair? x) (list? (cdr x)))))
EOF
    cat <prelude.scm >>init.scm
fi
cat <src/tower.scm >>init.scm

echo '(define tower (make-tower (quote (' >>init.scm
for SEXPFILE do
    cat $SEXPFILE >>init.scm
done
echo '))))' >>init.scm

if [ "${USE_EVAL}" = "yes" ]; then
    cat >>init.scm <<EOF
(eval tower (scheme-report-environment 5))
EOF
    ${SCHEME} init.scm
elif [ "${SCHEME}" = "miniscm" ]; then
    echo '(display tower) (quit)' >>init.scm
    cat <prelude.scm >next.scm
    echo '(display' >>next.scm
    ${SCHEME} -q >>next.scm
    echo ') (newline) (quit)' >>next.scm
    mv next.scm init.scm
    ${SCHEME} -q
else
    cat >>init.scm <<EOF
(display tower)
EOF
    echo >init.scm '(display'
    ${SCHEME} init.scm >>output.scm
    echo >>output.scm ') (newline)'
    ${SCHEME} output.scm
fi

rm -f init.scm output.scm prelude.scm
