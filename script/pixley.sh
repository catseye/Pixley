#!/bin/sh

# A little wrapper script for running Pixley programs from the command line.

# Usage: pixley.sh source.pix [s-expr.txt]

# TODO: take an 'n' parameter:
# 'n' is an integer which specifies how many nested copies of the Pixley
# interpreter you want to interpret your Pixley program in.
# n=1 interprets your program with a Pixley interpreter interpreted by Scheme,
# n=2 interprets your program with a Pixley interpreter interpreted by
#   a Pixley interpreter interpreted by Scheme,
# n=3 interprets your program with a Pixley interpreter interpreted by
#   a Pixley interpreter interpreted by a Pixley interpreter interpreted by
#   Scheme,
# and so forth.

# The second argument is optional; if it is given, it should be the name
# of a file which contains an S-expression. If it is given, the given
# Pixley program will be assumed to evaluate to a 1-argument function
# value; the S-expression will be passed to this function, and the result
# of the function will be output.

# This script requires a Scheme implementation which can run
# Scheme programs from the command line.  plt-r5rs does the trick.
# If you want to use a different Scheme implementation, you can set
# the environment variable R5RS before running this.

if [ "${R5RS}x" = "x" ]; then
    R5RS=plt-r5rs
fi

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`
PIXLEYDIR=${SCRIPTDIR}/../src/

cat >driver.scm <<EOF
(define pixley
EOF
cat ${PIXLEYDIR}/pixley.pix >>driver.scm 
cat >>driver.scm <<EOF
)
(define program (quote
EOF
cat >>driver.scm <$1
cat >>driver.scm <<EOF
))
EOF
if [ "${2}x" = "x" ]; then
    cat >>driver.scm <<EOF
(pixley pixley program '())
EOF
else
    cat >>driver.scm <<EOF
(define foonction (pixley pixley program '()))
(foonction (list (quote
EOF
    cat >>driver.scm <$2
    cat >>driver.scm <<EOF
)))
EOF
fi

$R5RS driver.scm

rm driver.scm
