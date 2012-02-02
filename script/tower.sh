#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation on how the "tower" idea works.

# The following comments are out of date.

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
# can set the environment variable CAN_EVAL to "no".  This causes this
# script to write the output of the tower function to a new file, and to
# evaluate it.

# The following Schemes have custom special support here:

# - tinyscheme: Tinyscheme does not support eval, so CAN_EVAL is set
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

SCHEME_CMD=$SCHEME_IMPL  # command to run for impl
CAN_EVAL=yes             # impl can eval s-exprs as Scheme progs?
EXPLICIT_QUIT=no         # impl needs explicit (quit) to stop?
NEED_EQUAL_P=no          # impl lacks `equal?`
NEED_LIST_P=no           # impl lacks `list?`
NEED_DUMP_SEXP=no        # impl needs extra support to write s-exp?

if [ "${SCHEME_IMPL}x" = "plt-r5rsx" ]; then
    # everything's good
    echo -n ''
elif [ "${SCHEME_IMPL}x" = "chibi-schemex" ]; then
    SCHEME_CMD='chibi-scheme -xscheme'
elif [ "${SCHEME_IMPL}x" = "tinyschemex" ]; then
    CAN_EVAL=no
    NEED_DUMP_SEXP=yes
elif [ "${SCHEME_IMPL}x" = "miniscmx" ]; then
    SCHEME_CMD='miniscm -q'
    CAN_EVAL=no
    EXPLICIT_QUIT=yes
    NEED_EQUAL_P=yes
    NEED_LIST_P=yes
    NEED_DUMP_SEXP=yes
fi

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`

cd ${SCRIPTDIR}/..

### Generate prelude ###

echo -n '' >prelude.scm

if [ "$NEED_EQUAL_P" = "yes" ]; then
    # define `equal?` in Scheme.  written by a.k.
    cat >>prelude.scm <<EOF
(define (equal? x y)
  (if (pair? x)
    (and (pair? y)
         (equal? (car x) (car y))
         (equal? (cdr x) (cdr y)))
    (and (not (pair? y))
         (eqv? x y))))
EOF
fi

if [ "$NEED_LIST_P" = "yes" ]; then
    # define `list?` in Scheme.  written by c.p.
    cat >>prelude.scm <<EOF
(define (list? x) (or (eq? x '()) (and (pair? x) (list? (cdr x)))))
EOF
fi

if [ "$NEED_DUMP_SEXP" = "yes" ]; then
    # extra support to dump a sexp (without abbreviating stuff)
    # written by c.p.
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

if [ "${CAN_EVAL}" = "yes" ]; then
    # Implementation can eval directly
    cat >>init.scm <<EOF
(define result (eval tower (scheme-report-environment 5)))
EOF
    echo '(display result) (newline)' >>init.scm
    ${SCHEME_CMD} init.scm
else
    # Implementation can't eval directly, so dump result to
    # another file and interpret it immediately afterward
    cat >>init.scm <<EOF
(display tower)
EOF
    if [ "${EXPLICIT_QUIT}" = "yes" ]; then
        echo '(quit)' >>init.scm
    fi

    cp prelude.scm next.scm
  
    if [ "$NEED_DUMP_SEXP" = "yes" ]; then
        echo '(dump-sexp' >>next.scm
        ${SCHEME_CMD} init.scm >>next.scm
        echo ') (newline)' >>next.scm
    else
        echo '(display' >>next.scm
        ${SCHEME_CMD} init.scm >>next.scm
        echo ') (newline)' >>next.scm
    fi
    if [ "${EXPLICIT_QUIT}" = "yes" ]; then
        echo '(quit)' >>next.scm
    fi

    mv next.scm init.scm
    ${SCHEME_CMD} init.scm
fi

### Clean up ###

rm -f init.scm next.scm prelude.scm
