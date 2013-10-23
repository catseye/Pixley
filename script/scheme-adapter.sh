#!/bin/sh

# Support various Scheme implementations in a standard way under POSIXoids.

# The thing with Scheme (<= R5RS) is that, well, it's never been big on
# defining its relationship with the environment.  The result is that rarely
# do you find two Scheme implementations that are invoked the same way and
# produce output the same way.  This script attempts to handle at least a few
# implementations so that they all behave like this:

#   scheme-adapter.sh prelude.scm expression.scm

# The contents of the file prelude.scm are evaluated as a Scheme program.
# Then the contents of the file expression.scm are evaluated as a Scheme
# expression, in the context of having evaluated prelude.scm, and the
# resulting value is printed to standard output, followed by a newline.

# When the resulting value is printed, quoted S-expressions are not
# abbreviated with the ' symbol.  Instead (quote ...) is printed verbatim.

# Example:

#   % echo '(define (plus x y) (+ x y))' > prelude.scm
#   % echo '(plus 1 2)' > expression.scm
#   % scheme-adapter.sh prelude.scm expression.scm
#   3
#   % 

# As a special case, if the first argument is "/dev/null", no prelude.scm
# program will be evaluated.

# No output from evaluating the prelude.scm program will be produced unless
# it specifically calls (display ...) or the like.

# Some caveats apply (Protip: some caveats *always* apply.)

# This script simply delegates to a wrapper script.  To find these wrapper
# scripts, 'realpath' is needed.

# This script provides support for four Scheme implementations.  Select
# the implementation of Scheme that you wish to use by setting the
# environment SCHEME_IMPL to one of the supported values (see wrapper scripts.)

# I was going to support chibi-scheme
# ( http://code.google.com/p/chibi-scheme/ ), but after some back-
# and-forth on whether it supports R5RS or not, the maintainer has
# said that "chibi is an R7RS scheme".  Since Pixley is not a subset
# of R7RS in any good sense, I dropped it.
#
# I was also going to support Bootstrap Scheme
# ( https://github.com/petermichaux/bootstrap-scheme ), but it turned
# out that Bootstrap Scheme doesn't even support let*, which is one
# of the core forms in Pixley; so if I did support it, it would only
# be able to run Pi[f]xlety, etc., and it just didn't seem worth it.
# So I dropped it too.
#
# I may change my mind on either or both of these in the future, but
# for now, they're not supported.
#
# If you have another implementation of Scheme you would like to
# support, please do feel free to contribute a wrapper for it.

SCRIPT=`realpath $0`
SCRIPTDIR=`dirname ${SCRIPT}`
WRAPPER="${SCRIPTDIR}/${SCHEME_IMPL}.sh"
exec ${WRAPPER} $1 $2
