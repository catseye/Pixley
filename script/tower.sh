#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation.

if [ "${R5RS}x" = "x" ]; then
    R5RS=plt-r5rs
fi

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`

cd ${SCRIPTDIR}/..
echo -n '' >init.scm
if [ $R5RS = your-weird-scheme ]; then
    cat >>init.scm <<EOF
(stuff (to support your weird scheme))
EOF
fi
cat <src/tower.scm >>init.scm
echo '(tower (quote (' >>init.scm
for SEXPFILE do
    cat $SEXPFILE >>init.scm
done
echo ')))' >>init.scm

${R5RS} init.scm
rm -f init.scm
