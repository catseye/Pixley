#!/bin/sh

# scheme-adapter.sh wrapper to support the Husk Scheme implementation

# - huski            # http://justinethier.github.io/husk-scheme/

echo -n '' >tmpprog.scm
cat $1 >>tmpprog.scm
echo "(display" >>tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

if [ ! "${DEBUG}x" = "x" ]; then
    less tmpprog.scm
fi

huski tmpprog.scm

rm -f tmpprog.scm
