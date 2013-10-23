#!/bin/sh

# Support various Scheme implementations as if they all behaved like
# plt-r5rs behaves, i.e.:

#   % echo '(+ 1 2)' > program.scm
#   % scheme-adapter.sh program.scm
#   3
#   % 

# Some caveats apply (Protip: some caveats *always* apply.)

echo "(display" >tmpprog.scm
cat $1 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

${SCHEME_IMPL} tmpprog.scm

