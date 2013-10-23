#!/bin/sh

# Support the tinyscheme Scheme implementation as if it behaved like
# plt-r5rs behaves, i.e.:

#   % echo '(+ 1 2)' > program.scm
#   % tinyscheme.sh program.scm
#   3
#   % 

# Note: if tinyscheme is installed from source, the executable's name
# will be 'scheme' and it will require 'init.scm' in the current
# directory.  However, if it is installed from a package (using apt-get,) the
# executable's name will be 'tinyscheme' and it will not require 'init.scm'
# in the current directory.  Just one of those cases where the package
# managers decide to try to make your life easier by making things obstensibly
# saner while at the same time introducing an incompatibility.
# 
# This wrapper assumes you have installed it from a package.

echo "(display" >tmpprog.scm
cat $1 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

tinyscheme tmpprog.scm

rm -f tmpprog.scm
