#!/bin/sh

if [ "${SCHEME_IMPL}x" = "x" ]; then
    # user didn't care to specify.  let's pick one.
    if [ ! -z `which miniscm` ]; then
        export SCHEME_IMPL=miniscm
    elif [ ! -z `which csi` ]; then
        export SCHEME_IMPL=csi
    elif [ ! -z `which huski` ]; then
        export SCHEME_IMPL=huski
    elif [ ! -z `which plt-r5rs` ]; then
        export SCHEME_IMPL=plt-r5rs
    else
        echo "No Scheme implementation (SCHEME_IMPL) selected, and"
        echo "no suitable Scheme implementation was found on your path."
        exit 1
    fi
fi
if [ `which ${SCHEME_IMPL}`x = "x" ]; then
    echo "Your selected Scheme implementation, $SCHEME_IMPL, was not found."
    exit 1
fi

if [ "${PIXLEY_IMPL}x" = "x" ]; then
    export PIXLEY_IMPL=mignon
fi

if [ "${PIXLEY_PIX}x" = "x" ]; then
    export PIXLEY_PIX=src/pixley.pix
fi

if [ `which realpath`x = "x" ]; then
    echo "You need 'realpath' installed to run tower.sh."
    exit 1
fi

echo "Sanity-testing tower.sh..."
cat >expected.sexp <<EOF
(two three)
EOF
script/tower.sh eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp
script/tower.sh $PIXLEY_PIX eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp
rm -f expected.sexp out.sexp
cat >expected.sexp <<EOF
(ten (eight nine) seven six five four three two one)
EOF
script/tower.sh eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp
script/tower.sh $PIXLEY_PIX eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp
rm -f expected.sexp out.sexp


echo "Testing Pixley programs on [${SCHEME_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Pixley programs on [${PIXLEY_IMPL}] (via scheme-adapter.sh)..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${PIXLEY_IMPL} script/scheme-adapter.sh /dev/null %(test-file)"
EOF
falderal test config.markdown src/tests.markdown

if [ "x$JUST_THE_BASICS" != "x" ]; then
    exit 0
fi

echo "Testing Pixley programs on [${PIXLEY_IMPL}] (via tower.sh)..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${SCHEME_IMPL} FINAL_SCHEME_IMPL=${PIXLEY_IMPL} script/tower.sh %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Pixley programs on Pixley interpreter on [${SCHEME_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh $PIXLEY_PIX %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Pixley programs on Pixley interpreter on [${PIXLEY_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${SCHEME_IMPL} FINAL_SCHEME_IMPL=${PIXLEY_IMPL} script/tower.sh $PIXLEY_PIX %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter on [${SCHEME_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh $PIXLEY_PIX $PIXLEY_PIX %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter on [${PIXLEY_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${SCHEME_IMPL} FINAL_SCHEME_IMPL=${PIXLEY_IMPL} script/tower.sh $PIXLEY_PIX $PIXLEY_PIX %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


# On my computer, the following test takes about 19 seconds on plt-r5rs, but
# about 32 minutes with tinyscheme -- possibly because of frequent GC?
# Meanwhile, it breaks miniscm completely.
#
#echo "Testing Pixley programs on (Pixley reference interpreter)^3..."
#cat >config.markdown <<EOF
#    -> Functionality "Interpret Pixley Program" is implemented by shell command
#    -> "script/tower.sh $PIXLEY_PIX $PIXLEY_PIX $PIXLEY_PIX %(test-file)"
#EOF
#falderal test config.markdown src/tests.markdown


# And if you have an hour or so to kill, you can try the next level up!
# (That's with plt-r5rs; I imagine tinyscheme would take much longer)
#
#echo "Testing Pixley programs on (Pixley reference interpreter)^4..."
#cat >config.markdown <<EOF
#    -> Functionality "Interpret Pixley Program" is implemented by shell command
#    -> "script/tower.sh $PIXLEY_PIX $PIXLEY_PIX $PIXLEY_PIX $PIXLEY_PIX %(test-file)"
#EOF
#time falderal test config.markdown src/tests.markdown


echo "Running Falderal tests for P-Normalizer..."
falderal test dialect/P-Normal.markdown


echo "P-Normalizing Pixley interpreter..."
script/tower.sh $PIXLEY_PIX dialect/p-normal.pix $PIXLEY_PIX > src/p-normal-pixley.pix
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/p-normal-pixley.pix %(test-file)"
EOF
echo "Testing Pixley programs on P-Normalized interpreter..."
falderal test config.markdown src/tests.markdown
rm -f src/p-normal-pixley.pix


echo "Testing Pixley programs on Pixley interpreter in Pifxley..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh dialect/pixley.pifx %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Pifxley programs as Scheme..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pifxley Program" is implemented by shell command
    -> "script/tower.sh %(test-file)"
EOF
falderal test config.markdown dialect/Pifxley.markdown


echo "Testing Pifxley programs on Pifxley interpreter in Pifxley..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pifxley Program" is implemented by shell command
    -> "script/tower.sh dialect/pifxley.pifx %(test-file)"
EOF
falderal test config.markdown dialect/Pifxley.markdown


echo "Testing Pixley programs on Crabwell interpreter..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh dialect/crabwell.pix %(test-file)"
EOF
falderal test config.markdown src/tests.markdown


echo "Testing Crabwell programs on Crabwell interpreter..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Crabwell Program" is implemented by shell command
    -> "script/tower.sh dialect/crabwell.pix %(test-file)"
EOF
falderal test config.markdown dialect/Crabwell.markdown
rm -f config.markdown
