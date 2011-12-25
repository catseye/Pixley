#!/bin/sh

# usage: tower.sh {interpreter.sexp | +} program.sexp

# See tower.scm for documentation.

if [ "${R5RS}x" = "x" ]; then
    R5RS=plt-r5rs
fi

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`

cd ${SCRIPTDIR}/..
cp src/tower.scm mytower.scm
echo -n '(tower (list ' >>mytower.scm
for SEXPFILE do
    echo -n '"'$SEXPFILE'" ' >>mytower.scm
done
echo -n '))' >>mytower.scm

${R5RS} mytower.scm
rm -f mytower.scm
