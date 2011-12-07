#!/bin/sh

# This is just a pure-Scheme counterpart to pixley.sh, to sanity-check
# that Pixley programs can also be interpreted as Scheme.

if [ "${R5RS}x" = "x" ]; then
    R5RS=plt-r5rs
fi

cat >driver.scm <<EOF
(define program
EOF
cat >>driver.scm <$1
cat >>driver.scm <<EOF
)
EOF
cat >>driver.scm <<EOF
(program (quote
EOF
cat >>driver.scm <$2
cat >>driver.scm <<EOF
))
EOF

$R5RS driver.scm

rm driver.scm
