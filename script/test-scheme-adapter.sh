#!/bin/sh

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/scheme-adapter.sh %(test-file)"
EOF

for IMPL in plt-r5rs huski script/tinyscheme.sh script/miniscm.sh; do
    echo "Testing Pixley programs as Scheme programs on ${IMPL}..."
    SCHEME_IMPL=$IMPL falderal test config.markdown src/tests.markdown
done

rm -f config.markdown tmpprog.scm init.scm