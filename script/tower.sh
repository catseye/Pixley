#!/bin/sh

# usage: tower.sh {interpreter.sexp} program.sexp

# See tower.scm for documentation on how the "tower" idea works.

# This script no longer tries to support multiple Scheme implementations.
# Instead, it relies on scheme-adapter.sh to do that for it.  Select
# the implementation of Scheme that you wish to use by setting the
# environment variable SCHEME_IMPL before running this script.

# If the environment variable FINAL_SCHEME_IMPL is set, that program will be
# used instead of SCHEME_IMPL when it comes time to run the resulting
# tower.  (SCHEME_IMPL will still be used to construct the tower.)

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

echo 'tower' >expression.scm
${SCRIPTDIR}/scheme-adapter.sh program.scm expression.scm >next.scm

if [ "${FINAL_SCHEME_IMPL}x" = "x" ]; then
    FINAL_SCHEME_IMPL=${SCHEME_IMPL}
fi

if [ ! "${DEBUG_TOWER}x" = "x" ]; then
    less next.scm
fi

SCHEME_IMPL=${FINAL_SCHEME_IMPL} ${SCRIPTDIR}/scheme-adapter.sh /dev/null next.scm

### Clean up ###

rm -f init.scm next.scm program.scm expression.scm
