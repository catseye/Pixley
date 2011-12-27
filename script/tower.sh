#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation on how the "tower" idea works.

# This script is somewhat convoluted because it supports several Scheme
# implementations with different ideas about what they support, and how
# they would like to interact with the rest of the world.

# Set the environment variable SCHEME to the name of your Scheme
# implementation.  If SCHEME is not set, plt-r5rs (from the Racket
# distribution, downloadable from http://racket-lang.org/) is used.  This
# implementation supports eval and does what you expect when you say
# "plt-r5rs foo.scm", so there are no special considerations to take for
# it.  If your Scheme works like this too, there should be no problems.

# If you have a Scheme implementation which does not support eval, you
# can set the environment variable USE_EVAL to "no".  This causes this
# script to write the output of the tower function to a new file, and to
# evaluate it.

# The following Schemes have custom special support here:

# - tinyscheme: Tinyscheme does not support eval, so USE_EVAL is set
#   to "no".  In addition, it insists on abbreviating quoted
#   S-expressions during output (i.e. it will print "'(q)" instead of
#   "(quote (q))",) so it produces output that some of the tests
#   don't expect.  To work around this, this script prepends a prelude
#   to the generated Scheme source which provides a function which
#   dumps S-expressions the way the tests expect.

# - miniscm: Mini-Scheme is supported, but a somewhat enhanced version
#   (available from https://github.com/catseye/minischeme) which
#   supports a -q option to suppress non-explicit output is required.
#   Like Tinyscheme, Mini-Scheme does not support eval, and
#   miniscm insists on abbreviating quoted S-expressions too, so the
#   considerations for Tinyscheme apply for Mini-Scheme too.
#   And, since miniscm reads only the init.scm file at startup, this
#   script generates a file by that name and starts miniscm on it.
#   To support this, the generated prelude further contains some
#   procedures which miniscm's core lacks, but which are required to
#   run Pixley programs.

### Initialization ###

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

### Generate prelude ###

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

### Create the tower ###

cp prelude.scm init.scm
cat <src/tower.scm >>init.scm
echo '(define tower (make-tower (quote (' >>init.scm
for SEXPFILE do
    cat $SEXPFILE >>init.scm
done
echo '))))' >>init.scm

if [ "${USE_EVAL}" = "yes" ]; then
    ### plt-r5rs or similar -- can eval ###
    cat >>init.scm <<EOF
(eval tower (scheme-report-environment 5))
EOF
    ${SCHEME} init.scm
elif [ "${SCHEME}" = "miniscm" ]; then
    ### Mini-Scheme is special ###
    echo '(display tower) (quit)' >>init.scm
    cat <prelude.scm >next.scm
    echo '(dump-sexp' >>next.scm
    ${SCHEME} -q >>next.scm
    echo ') (newline) (quit)' >>next.scm
    mv next.scm init.scm
    ${SCHEME} -q
else
    ### Tinyscheme or similar -- can't eval ###
    cat >>init.scm <<EOF
(display tower)
EOF
    cp prelude.scm output.scm
    echo >>output.scm '(dump-sexp'
    ${SCHEME} init.scm >>output.scm
    echo >>output.scm ') (newline)'
    ${SCHEME} output.scm
fi

### Clean up ###

rm -f init.scm output.scm prelude.scm
