#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation on how the "tower" idea works.

# This script provides supports three Scheme implementations.  Select
# the implementation of Scheme that you wish to use by setting the
# environment SCHEME_IMPL to one of the following values:
#
# - plt-r5rs         # http://racket-lang.org/
# - tinyscheme       # http://tinyscheme.sourceforge.net/
# - miniscm          # https://github.com/catseye/minischeme
#
# I was going to support chibi-scheme
# ( http://code.google.com/p/chibi-scheme/ ), but after some back-
# and-forth on whether it supports R5RS or not, the maintainer has
# said that "chibi is an R7RS scheme".  Since Pixley is not a subset
# of R7RS in any good sense, I dropped it.
#
# I was also going to support Bootstrap Scheme
# ( https://github.com/petermichaux/bootstrap-scheme ), but it turned
# out that Bootstrap Scheme doesn't even support let*, which is one
# of the core forms in Pixley; so if I did support it, it would only
# be able to run Pi[f]xlety, etc., and it just didn't seem worth it.
# So I dropped it too.
#
# I may change my mind on either or both of these in the future, but
# for now, they're not supported.
#
# If you have another implementation of Scheme you would like to
# support, figure out which of the listed capabilities are
# appropriate for it, and add it to the if/elif/fi chain in the
# Initialization section.

### Initialization ###

SCHEME_CMD=$SCHEME_IMPL  # command to run for impl
CAN_EVAL=yes             # impl can eval s-exprs as Scheme progs?
EXPLICIT_QUIT=no         # impl needs explicit (quit) to stop?
NEED_EQUAL_P=no          # impl lacks `equal?`
NEED_LIST_P=no           # impl lacks `list?`
NEED_DUMP_SEXP=no        # impl needs extra support to write s-exp?

if [ "${SCHEME_IMPL}x" = "plt-r5rsx" ]; then
    # The default capabilities are fine for plt-r5rs.
    echo -n ''
elif [ "${SCHEME_IMPL}x" = "tinyschemex" ]; then
    # Tinyscheme insists on abbreviating quoted S-expressions
    # during output -- i.e., it will print "'(q)" instead of
    # "(quote (q))" -- so it produces output that some of the tests
    # don't expect.  To work around this, this script prepends a
    # definition of a function "dump-sexp" which explicitly formats
    # the resulting S-expression in the way the tests do expect.
    SCHEME_CMD='script/tinyscheme.sh'
    NEED_DUMP_SEXP=yes
elif [ "${SCHEME_IMPL}x" = "miniscmx" ]; then
    # Mini-Scheme is supported, but version 0.85p1 (a fork available
    # at the above URL) is required to support the -q and -e options.
    # Like Tinyscheme, Mini-Scheme insists on abbreviating quoted sexps,
    # so the considerations for Tinyscheme apply for Mini-Scheme too.
    # miniscm's core lacks "equal?" and "list?", so definitions for
    # those are also prepended to the source we want to run.
    SCHEME_CMD='script/miniscm.sh'
    NEED_DUMP_SEXP=yes
else
    echo "Please set SCHEME_IMPL to one of the following:"
    echo "plt-r5rs, tinyscheme, miniscm"
    exit 1
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

cp prelude.scm program.scm
cat <src/tower.scm >>program.scm
echo '(define tower (make-tower (quote (' >>program.scm
for SEXPFILE do
    cat $SEXPFILE >>program.scm
done
echo '))))' >>program.scm

# We don't mess around with 'eval'.  We dump the result to
# another file and interpret it immediately afterward instead.
cat >>program.scm <<EOF
(display tower)
EOF
if [ "${EXPLICIT_QUIT}" = "yes" ]; then
    echo '(quit)' >>program.scm
fi

if [ ! "${DEBUG}x" = "x" ]; then
    less program.scm
fi

cp prelude.scm next.scm

if [ "$NEED_DUMP_SEXP" = "yes" ]; then
    echo '(dump-sexp' >>next.scm
    ${SCHEME_CMD} program.scm >>next.scm
    echo ') (newline)' >>next.scm
else
    echo '(display' >>next.scm
    ${SCHEME_CMD} program.scm >>next.scm
    echo ') (newline)' >>next.scm
fi
if [ "${EXPLICIT_QUIT}" = "yes" ]; then
    echo '(quit)' >>next.scm
fi

mv next.scm program.scm
${SCHEME_CMD} program.scm

### Clean up ###

rm -f init.scm next.scm prelude.scm
