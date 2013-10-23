#!/bin/sh

# scheme-adapter.sh wrapper to support the plt-r5rs Scheme implementation

# - plt-r5rs         # http://racket-lang.org/

echo -n '' >tmpprog.scm
if [ ! "$1"x = "/dev/nullx" ]; then
    cat $1 >>tmpprog.scm
fi
echo "(display" >tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

if [ ! "${DEBUG}x" = "x" ]; then
    less tmpprog.scm
fi

plt-r5rs tmpprog.scm

rm -f tmpprog.scm
