#!/bin/sh

if [ "${SCHEME_IMPL}x" = "x" ]; then
    # user didn't care to specify.  let's pick one.
    if [ ! -z `which csi` ]; then
        export SCHEME_IMPL=csi
    elif [ ! -z `which huski` ]; then
        export SCHEME_IMPL=huski
    elif [ ! -z `which plt-r5rs` ]; then
        export SCHEME_IMPL=plt-r5rs
    elif [ ! -z `which miniscm` ]; then
        export SCHEME_IMPL=miniscm
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
diff -u expected.sexp out.sexp || exit 1
script/tower.sh $PIXLEY_PIX eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp || exit 1
rm -f expected.sexp out.sexp
cat >expected.sexp <<EOF
(ten (eight nine) seven six five four three two one)
EOF
script/tower.sh eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp || exit 1
script/tower.sh $PIXLEY_PIX eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp || exit 1
rm -f expected.sexp out.sexp


echo "Testing Pixley programs on [${SCHEME_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1

echo "Testing Pixley programs on [${PIXLEY_IMPL}] (via scheme-adapter.sh)..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${PIXLEY_IMPL} script/scheme-adapter.sh /dev/null %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1

if [ "x$JUST_THE_BASICS" != "x" ]; then
    exit 0
fi

echo "Testing Pixley programs on [${PIXLEY_IMPL}] (via tower.sh)..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${SCHEME_IMPL} FINAL_SCHEME_IMPL=${PIXLEY_IMPL} script/tower.sh %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


echo "Testing Pixley programs on Pixley interpreter on [${SCHEME_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh $PIXLEY_PIX %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


echo "Testing Pixley programs on Pixley interpreter on [${PIXLEY_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${SCHEME_IMPL} FINAL_SCHEME_IMPL=${PIXLEY_IMPL} script/tower.sh $PIXLEY_PIX %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter on [${SCHEME_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh $PIXLEY_PIX $PIXLEY_PIX %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


echo "Testing Pixley programs on Pixley interpreter on Pixley interpreter on [${PIXLEY_IMPL}]..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "SCHEME_IMPL=${SCHEME_IMPL} FINAL_SCHEME_IMPL=${PIXLEY_IMPL} script/tower.sh $PIXLEY_PIX $PIXLEY_PIX %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


# On my computer, the following test takes about 19 seconds on plt-r5rs, but
# about 32 minutes with tinyscheme -- possibly because of frequent GC?
# Meanwhile, it breaks miniscm completely.
#
#echo "Testing Pixley programs on (Pixley reference interpreter)^3..."
#cat >config.markdown <<EOF
#    -> Functionality "Interpret Pixley Program" is implemented by shell command
#    -> "script/tower.sh $PIXLEY_PIX $PIXLEY_PIX $PIXLEY_PIX %(test-body-file)"
#EOF
#falderal config.markdown src/tests.markdown || exit 1


# And if you have an hour or so to kill, you can try the next level up!
# (That's with plt-r5rs; I imagine tinyscheme would take much longer)
#
#echo "Testing Pixley programs on (Pixley reference interpreter)^4..."
#cat >config.markdown <<EOF
#    -> Functionality "Interpret Pixley Program" is implemented by shell command
#    -> "script/tower.sh $PIXLEY_PIX $PIXLEY_PIX $PIXLEY_PIX $PIXLEY_PIX %(test-body-file)"
#EOF
#falderal config.markdown src/tests.markdown || exit 1


echo "Running Falderal tests for P-Normalizer..."
falderal dialect/P-Normal.markdown || exit 1


echo "P-Normalizing Pixley interpreter..."
script/tower.sh $PIXLEY_PIX dialect/p-normal.pix $PIXLEY_PIX > src/p-normal-pixley.pix
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh src/p-normal-pixley.pix %(test-body-file)"
EOF
echo "Testing Pixley programs on P-Normalized interpreter..."
falderal config.markdown src/tests.markdown || exit 1
rm -f src/p-normal-pixley.pix


echo "Testing Pixley programs on Pixley interpreter in Pifxley..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh dialect/pixley.pifx %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


echo "Testing Pifxley programs as Scheme..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pifxley Program" is implemented by shell command
    -> "script/tower.sh %(test-body-file)"
EOF
falderal config.markdown dialect/Pifxley.markdown || exit 1


echo "Testing Pifxley programs on Pifxley interpreter in Pifxley..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pifxley Program" is implemented by shell command
    -> "script/tower.sh dialect/pifxley.pifx %(test-body-file)"
EOF
falderal config.markdown dialect/Pifxley.markdown || exit 1


echo "Testing Pixley programs on Crabwell interpreter..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Pixley Program" is implemented by shell command
    -> "script/tower.sh dialect/crabwell.pix %(test-body-file)"
EOF
falderal config.markdown src/tests.markdown || exit 1


echo "Testing Crabwell programs on Crabwell interpreter..."
cat >config.markdown <<EOF
    -> Functionality "Interpret Crabwell Program" is implemented by shell command
    -> "script/tower.sh dialect/crabwell.pix %(test-body-file)"
EOF
falderal config.markdown dialect/Crabwell.markdown || exit 1
rm -f config.markdown
