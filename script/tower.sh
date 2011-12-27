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

# Create prelude
echo -n '' >prelude.scm
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
fi

if [ "$SCHEME" = "miniscm" -o "$SCHEME" = "tinyscheme" ]; then
    cat >>prelude.scm <<EOF
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
fi

# Create the tower-maker
cp prelude.scm init.scm
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
    echo '(dump-sexp' >>next.scm
    ${SCHEME} -q >>next.scm
    echo ') (newline) (quit)' >>next.scm
    mv next.scm init.scm
    ${SCHEME} -q
else
    cat >>init.scm <<EOF
(display tower)
EOF
    cp prelude.scm output.scm
    echo >>output.scm '(dump-sexp'
    ${SCHEME} init.scm >>output.scm
    echo >>output.scm ') (newline)'
    ${SCHEME} output.scm
fi

rm -f init.scm output.scm prelude.scm
