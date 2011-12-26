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
echo -n '' >t.scm
if [ "$SCHEME" = "your-weird-scheme" ]; then
    cat >>t.scm <<EOF
(stuff (to support your weird scheme))
EOF
fi
cat <src/tower.scm >>t.scm

echo '(define tower (make-tower (quote (' >>t.scm
for SEXPFILE do
    cat $SEXPFILE >>t.scm
done
echo '))))' >>t.scm

if [ "${USE_EVAL}" = "yes" ]; then
    cat >>t.scm <<EOF
(eval tower (scheme-report-environment 5))
EOF
    ${SCHEME} t.scm
else
    cat >>t.scm <<EOF
(display tower)
EOF
    echo >init.scm '(display'
    ${SCHEME} t.scm >>init.scm
    echo >>init.scm ') (newline)'
    ${SCHEME} init.scm
fi

rm -f t.scm init.scm
