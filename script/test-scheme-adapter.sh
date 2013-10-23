#!/bin/sh

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/scheme-adapter.sh /dev/null %(test-file)"
EOF

for IMPL in plt-r5rs huski tinyscheme miniscm; do
    echo "Testing Pixley programs as Scheme programs on ${IMPL}..."
    SCHEME_IMPL=$IMPL falderal test config.markdown src/tests.markdown
done

rm -f config.markdown tmpprog.scm init.scm
