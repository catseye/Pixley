#!/bin/sh

IMPLS="plt-r5rs huski tinyscheme miniscm"

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/scheme-adapter.sh /dev/null %(test-file)"
EOF

for IMPL in $IMPLS; do
    echo "Testing Pixley programs as Scheme programs on ${IMPL}..."
    SCHEME_IMPL=$IMPL falderal test config.markdown src/tests.markdown
done

# test that prelude.scm is actually loaded and stuff

cat >prelude.scm <<EOF
(define gerbil (quote hamster))
(display gerbil)
(define zork (lambda (x y) (cons x (cons y (quote ())))))
EOF

cat >test-scheme-adapter.markdown <<EOF
    -> Tests for functionality "Use Scheme Adapter"

    -> Functionality "Use Scheme Adapter" is implemented by shell command
    -> "script/scheme-adapter.sh prelude.scm %(test-file)"

    | (quote hello)
    = hamsterhello

    | (zork (quote a) (quote b))
    = hamster(a b)
EOF

for IMPL in $IMPLS; do
    echo "Testing Scheme adapter on ${IMPL}..."
    SCHEME_IMPL=$IMPL falderal test test-scheme-adapter.markdown
done

rm -f config.markdown tmpprog.scm init.scm prelude.scm test-scheme-adapter.markdown
