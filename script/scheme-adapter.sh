#!/bin/sh

echo "(display" >tmpprog.scm
cat $1 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

${SCHEME_IMPL} tmpprog.scm

