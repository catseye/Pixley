#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation on how the "tower" idea works.

# This script no longer tries to support multiple Scheme implementations.
# Instead, it relies on scheme-adapter.sh to do that for it.  Select
# the implementation of Scheme that you wish to use by setting the
# environment variable SCHEME_IMPL before running this script.

### Initialization ###

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`

### Create the tower ###

cp ${SCRIPTDIR}/../src/tower.scm program.scm
echo '(define tower (make-tower (quote (' >>program.scm
for SEXPFILE do
    cat $SEXPFILE >>program.scm
done
echo '))))' >>program.scm

# We don't mess around with 'eval'.  We dump the result to
# another file and interpret it immediately afterward instead.

if [ ! "${DEBUG}x" = "x" ]; then
    less program.scm
fi

echo 'tower' >expression.scm
${SCRIPTDIR}/scheme-adapter.sh program.scm expression.scm >next.scm

if [ ! "${DEBUG}x" = "x" ]; then
    less next.scm
fi

${SCRIPTDIR}/scheme-adapter.sh /dev/null next.scm

### Clean up ###

rm -f init.scm next.scm program.scm expression.scm
