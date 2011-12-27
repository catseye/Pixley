#!/bin/sh

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
falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh %(test) >%(output)"' src/tests.falderal

echo "Testing Pixley programs on Pixley reference interpreter..."
falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh src/pixley.pix %(test) >%(output)"' src/tests.falderal

echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter..."
falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh src/pixley.pix src/pixley.pix %(test) >%(output)"' src/tests.falderal

# On my computer, the following test takes about 19 seconds on plt-r5rs, but
# about 32 minutes with tinyscheme -- possibly because of frequent GC?
# Meanwhile, it breaks miniscm completely.

# echo "Testing Pixley programs on (Pixley reference interpreter)^3..."
# falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh src/pixley.pix src/pixley.pix src/pixley.pix %(test) >%(output)"' src/tests.falderal

# And if you have an hour or so to kill, you can try the next level up!
# (That's with plt-r5rs; I imagine tinyscheme would take much longer)

# echo "Testing Pixley programs on (Pixley reference interpreter)^4..."
# time falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh src/pixley.pix src/pixley.pix src/pixley.pix src/pixley.pix %(test) >%(output)"' src/tests.falderal

# Tinyscheme and minischeme don't pass this yet, because they insist on
# abbreviating quote forms in their output.
echo "Running Falderal tests for P-Normalizer..."
falderal test dialect/p-normal.falderal

echo "P-Normalizing Pixley interpreter..."
script/tower.sh src/pixley.pix dialect/p-normal.pix src/pixley.pix > src/p-normal-pixley.pix

echo "Testing Pixley programs on P-Normalized interpreter..."
falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh src/p-normal-pixley.pix %(test) >%(output)"' src/tests.falderal

rm -f src/p-normal-pixley.pix

echo "Testing Pixley programs on Pixley interpreter in Pifxley..."
falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh dialect/pixley.pifx %(test) >%(output)"' src/tests.falderal

echo "Testing Pifxley programs as Scheme..."
falderal test -f 'Interpret Pifxley Program:shell command "script/tower.sh %(test) >%(output)"' dialect/pifxley.falderal

echo "Testing Pifxley programs on Pifxley interpreter in Pifxley..."
falderal test -f 'Interpret Pifxley Program:shell command "script/tower.sh dialect/pifxley.pifx %(test) >%(output)"' dialect/pifxley.falderal

echo "Testing Pixley programs on Crabwell interpreter..."
falderal test -f 'Interpret Pixley Program:shell command "script/tower.sh dialect/crabwell.pix %(test) >%(output)"' src/tests.falderal

echo "Testing Crabwell programs on Crabwell interpreter..."
falderal test -f 'Interpret Crabwell Program:shell command "script/tower.sh dialect/crabwell.pix %(test) >%(output)"' dialect/crabwell.falderal
