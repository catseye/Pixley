#!/bin/sh

# scheme-adapter.sh wrapper to support the Chicken Scheme interpreter

echo -n '' >tmpprog.scm
cat $1 >>tmpprog.scm
echo "(display" >>tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

if [ ! "${DEBUG}x" = "x" ]; then
    less tmpprog.scm
fi

csi -s tmpprog.scm

rm -f tmpprog.scm
