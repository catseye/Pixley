#!/bin/sh

echo "Sanity-testing scheme.sh and pixley.sh..."

cat >expected.sexp <<EOF
(two three)
EOF
script/scheme.sh eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp
script/pixley.sh eg/simple.pix > out.sexp
diff -u expected.sexp out.sexp
rm -f expected.sexp out.sexp

cat >expected.sexp <<EOF
(ten (eight nine) seven six five four three two one)
EOF
script/scheme.sh eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp
script/pixley.sh eg/reverse.pix eg/some-list.sexp > out.sexp
diff -u expected.sexp out.sexp
rm -f expected.sexp out.sexp

echo "Testing Pixley programs as Scheme programs..."

cd src && PIXLEY=R5RS falderal test tests.falderal
rm -f foo.pix
cd ..

echo "Testing Pixley programs on reference interpreter..."

cd src && falderal test tests.falderal
rm -f foo.pix
cd ..

echo "Running Falderal tests for P-Normalizer..."

cd dialect && falderal test p-normal.falderal
rm -f foo.pix
cd ..

echo "P-Normalizing Pixley interpreter..."

script/pixley.sh dialect/p-normal.pix src/pixley.pix > src/p-normal-pixley.pix

echo "Testing Pixley programs on P-Normalized interpreter..."

cd src && PIXLEY=p-normal-pixley.pix falderal test tests.falderal
rm -f foo.pix p-normal-pixley.pix
cd ..

echo "Testing Pixley programs on Pixley interpreter in Pifxley..."

cd src && PIXLEY=../dialect/pixley.pifx falderal test tests.falderal
rm -f foo.pix p-normal-pixley.pix
cd ..

# Optional Mini-Scheme tests

echo 'quit' | miniscm >/dev/null 2>&1
if [ $? = 0 ]
  then
    echo "Right on, you have miniscm installed.  Testing Pixley on it..."
    cd src
    cat >expected.out <<EOF
> a
> 
EOF
    echo '(pixley2 (quote (let* ((a (quote a))) a)))' | miniscm 2>&1 | grep '^>' > miniscm.out
    diff -u expected.out miniscm.out
    rm -f expected.out miniscm.out
    cd ..
  else
    echo "miniscm not installed, skipping.  Your loss I guess."
fi
