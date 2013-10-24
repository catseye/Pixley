#!/bin/sh

# scheme-adapter.sh wrapper to support the tinyscheme Scheme implementation

# - tinyscheme       # http://tinyscheme.sourceforge.net/

# Note: if tinyscheme is installed from source, the executable's name
# will be 'scheme' and it will require 'init.scm' in the current
# directory.  However, if it is installed from a package (using apt-get,) the
# executable's name will be 'tinyscheme' and it will not require 'init.scm'
# in the current directory.  Just one of those cases where the package
# managers decide to try to make your life easier by making things obstensibly
# saner while at the same time introducing an incompatibility.
# 
# This wrapper assumes you have installed it from a package.

# Tinyscheme insists on abbreviating quoted S-expressions
# during output -- i.e., it will print "'(q)" instead of
# "(quote (q))" -- so it produces output that some of the tests
# don't expect.  To work around this, this script prepends a
# definition of a function "dump-sexp" which explicitly formats
# the resulting S-expression in the way the tests do expect.

echo -n '' >tmpprog.scm
cat $1 >>tmpprog.scm

cat >>tmpprog.scm <<EOF
(define dump-sexp-tail
  (lambda (sexp)
    (cond
      ((null? sexp)
        (display ")"))
      ((pair? sexp)
        (dump-sexp (car sexp))
        (if (null? (cdr sexp))
           (display ")")
           (begin
             (display " ")
             (dump-sexp-tail (cdr sexp)))))
      (else
        (display ". ")
        (dump-sexp sexp)
        (display ")")))))

(define dump-sexp
  (lambda (sexp)
    (cond
      ((pair? sexp)
        (display "(") (dump-sexp-tail sexp))
      (else
        (display sexp)))))
EOF

echo "(dump-sexp" >>tmpprog.scm
cat $2 >>tmpprog.scm
echo ") (newline)" >>tmpprog.scm

if [ ! "${DEBUG}x" = "x" ]; then
    less tmpprog.scm
fi

tinyscheme tmpprog.scm

rm -f tmpprog.scm
