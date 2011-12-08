#!/bin/sh

# run Falderal tests
cd src && falderal test tests.falderal
rm -f foo.pix
cd ..

# sanity-test scheme.sh and pixley.sh
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

# test p-normalization
cd eg && falderal test p-normal.falderal
rm -f foo.pix
cd ..

# test miniscm
cd src
cat >expected.out <<EOF
> a
> 
EOF
echo '(pixley2 (quote (let* ((a (quote a))) a)))' | miniscm 2>&1 | grep '^>' > miniscm.out
diff -u expected.out miniscm.out
rm -f expected.out miniscm.out
