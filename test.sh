#!/bin/sh

if [ "${SCHEME_IMPL}x" = "x" ]; then
    export SCHEME_IMPL=plt-r5rs
fi

if [ -z `which $SCHEME_IMPL`]; then
    echo "Your selected Scheme implementation, $SCHEME_IMPL, was not found."
    exit 1
fi

echo "Sanity-testing tower.sh..."

cat >expected.sexp <<EOF
(two three)
EOF
script/tower.sh eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp
script/tower.sh src/pixley.pix eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp
rm -f expected.sexp out.sexp

cat >expected.sexp <<EOF
(ten (eight nine) seven six five four three two one)
EOF
script/tower.sh eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp
script/tower.sh src/pixley.pix eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp
rm -f expected.sexp out.sexp

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh %(test-file)"
EOF
echo "Testing Pixley programs as Scheme programs..."
falderal test config.markdown src/tests.markdown

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/pixley.pix %(test-file)"
EOF
echo "Testing Pixley programs on Pixley reference interpreter..."
falderal test config.markdown src/tests.markdown

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/pixley.pix src/pixley.pix %(test-file)"
EOF
echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter..."
falderal test config.markdown src/tests.markdown

# On my computer, the following test takes about 19 seconds on plt-r5rs, but
# about 32 minutes with tinyscheme -- possibly because of frequent GC?
# Meanwhile, it breaks miniscm completely.

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/pixley.pix src/pixley.pix src/pixley.pix %(test-file)"
EOF

# echo "Testing Pixley programs on (Pixley reference interpreter)^3..."
# falderal test config.markdown src/tests.markdown

# And if you have an hour or so to kill, you can try the next level up!
# (That's with plt-r5rs; I imagine tinyscheme would take much longer)

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/pixley.pix src/pixley.pix src/pixley.pix src/pixley.pix %(test-file)"
EOF

# echo "Testing Pixley programs on (Pixley reference interpreter)^4..."
# time falderal test config.markdown src/tests.markdown

echo "Running Falderal tests for P-Normalizer..."
falderal test dialect/P-Normal.markdown

echo "P-Normalizing Pixley interpreter..."
script/tower.sh src/pixley.pix dialect/p-normal.pix src/pixley.pix > src/p-normal-pixley.pix

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/p-normal-pixley.pix %(test-file)"
EOF
echo "Testing Pixley programs on P-Normalized interpreter..."
falderal test config.markdown src/tests.markdown

rm -f src/p-normal-pixley.pix

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh dialect/pixley.pifx %(test-file)"
EOF
echo "Testing Pixley programs on Pixley interpreter in Pifxley..."
falderal test config.markdown src/tests.markdown

cat >config.markdown <<EOF
    -> Functionality "Interpret Pifxley Program" is implemented by shell command
    -> "script/tower.sh %(test-file)"
EOF
echo "Testing Pifxley programs as Scheme..."
falderal test config.markdown dialect/Pifxley.markdown

cat >config.markdown <<EOF
    -> Functionality "Interpret Pifxley Program" is implemented by shell command
    -> "script/tower.sh dialect/pifxley.pifx %(test-file)"
EOF
echo "Testing Pifxley programs on Pifxley interpreter in Pifxley..."
falderal test config.markdown dialect/Pifxley.markdown

cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh dialect/crabwell.pix %(test-file)"
EOF
echo "Testing Pixley programs on Crabwell interpreter..."
falderal test config.markdown src/tests.markdown

cat >config.markdown <<EOF
    -> Functionality "Interpret Crabwell Program" is implemented by shell command
    -> "script/tower.sh dialect/crabwell.pix %(test-file)"
EOF
echo "Testing Crabwell programs on Crabwell interpreter..."
falderal test config.markdown dialect/Crabwell.markdown

rm -f config.markdown
