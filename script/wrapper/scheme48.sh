#!/bin/sh

# scheme-adapter.sh wrapper to support Scheme48
# http://www.s48.org/

# Some considerations:
# - No way to tell scheme48 to load a Scheme source, so we shove it
#   in on standard input.
# - No way to tell scheme48 to not print its interactive prompt stuff,
#   so we redirect output to /dev/null, and open an output port to a
#   temporary file, for the output we actually want.  Then we cat that
#   to out standard output.
# - Upon reaching the end of standard input, scheme48 doesn't just
#   terminate, like 99.71% of command-line programs.  Oh no.  It asks
#   you if you really want to quit [y/n].  So, we explicitly end our
#   source with scheme48's explicit quit command, ",exit 0".
# - scheme48 abbreviates (quote ...) as '... by default, so we use the
#   dump-sexp procedure (modified slightly to use the output-port.)

echo -n '' >tmpprog.scm
cat $1 >>tmpprog.scm
echo '(call-with-output-file "tmpoutput.txt"' >>tmpprog.scm
echo '  (lambda (output-port)' >>tmpprog.scm

cat >>tmpprog.scm <<EOF
(define dump-sexp-tail
  (lambda (sexp)
    (cond
      ((null? sexp)
        (display ")" output-port))
      ((pair? sexp)
        (dump-sexp (car sexp))
        (if (null? (cdr sexp))
           (display ")" output-port)
           (begin
             (display " " output-port)
             (dump-sexp-tail (cdr sexp)))))
      (else
        (display ". " output-port)
        (dump-sexp sexp)
        (display ")" output-port)))))

(define dump-sexp
  (lambda (sexp)
    (cond
      ((pair? sexp)
        (display "(" output-port) (dump-sexp-tail sexp))
      (else
        (display sexp output-port)))))
EOF

echo '    (dump-sexp ' >>tmpprog.scm
cat $2 >>tmpprog.scm
echo '     )))' >>tmpprog.scm
echo ",exit 0" >>tmpprog.scm

if [ ! "${DEBUG}x" = "x" ]; then
    less tmpprog.scm
fi

scheme48 <tmpprog.scm >/dev/null
cat tmpoutput.txt
echo

rm -f tmpprog.scm tmpoutput.txt
