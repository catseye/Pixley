#!/bin/sh

if [ "${SCHEME_IMPL}x" = "x" ]; then
    export SCHEME_IMPL=plt-r5rs
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

echo "Testing Pixley programs as Scheme programs..."
falderal test tests/config/Pixley-as-Scheme.markdown src/tests.markdown

echo "Testing Pixley programs on Pixley reference interpreter..."
falderal test tests/config/Pixley-as-Pixley.markdown src/tests.markdown

echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter..."
falderal test tests/config/Pixley-as-Pixley^2.markdown src/tests.markdown

# On my computer, the following test takes about 19 seconds on plt-r5rs, but
# about 32 minutes with tinyscheme -- possibly because of frequent GC?
# Meanwhile, it breaks miniscm completely.

# echo "Testing Pixley programs on (Pixley reference interpreter)^3..."
# falderal test tests/config/Pixley-as-Pixley^3.markdown src/tests.markdown

# And if you have an hour or so to kill, you can try the next level up!
# (That's with plt-r5rs; I imagine tinyscheme would take much longer)

# echo "Testing Pixley programs on (Pixley reference interpreter)^4..."
# time falderal test tests/config/Pixley-as-Pixley^4.markdown src/tests.markdown

echo "Running Falderal tests for P-Normalizer..."
falderal test dialect/P-Normal.markdown

echo "P-Normalizing Pixley interpreter..."
script/tower.sh src/pixley.pix dialect/p-normal.pix src/pixley.pix > src/p-normal-pixley.pix

echo "Testing Pixley programs on P-Normalized interpreter..."
falderal test tests/config/Pixley-on-P-Normal-Pixley.markdown src/tests.markdown

rm -f src/p-normal-pixley.pix

echo "Testing Pixley programs on Pixley interpreter in Pifxley..."
falderal test tests/config/Pixley-on-Pifxley.markdown src/tests.markdown

echo "Testing Pifxley programs as Scheme..."
falderal test tests/config/Pifxley-as-Scheme.markdown dialect/Pifxley.markdown

echo "Testing Pifxley programs on Pifxley interpreter in Pifxley..."
falderal test tests/config/Pifxley-as-Pifxley.markdown dialect/Pifxley.markdown

echo "Testing Pixley programs on Crabwell interpreter..."
falderal test tests/config/Pixley-on-Crabwell.markdown src/tests.markdown

echo "Testing Crabwell programs on Crabwell interpreter..."
falderal test tests/config/Crabwell-as-Crabwell.markdown dialect/Crabwell.markdown
