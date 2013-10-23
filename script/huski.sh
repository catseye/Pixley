#!/bin/sh

# scheme-adapter.sh wrapper to support the Husk Scheme implementation

echo -n '' >tmpprog.scm
if [ ! "$1"x = "/dev/nullx" ]; then
    cat $1 >>tmpprog.scm
fi
echo "(display" >tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

huski tmpprog.scm

rm -f tmpprog.scm
