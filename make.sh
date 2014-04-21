#!/bin/sh

cd impl/mignon && ANSI=yes make || exit 1
cd ../..
if [ ! x`which ghc` = x ]; then
  cd impl/haney && make || exit 1
fi
cd ../..
