#!/bin/sh

cd impl/mignon && ANSI=yes make || exit 1
cd ../..
cd impl/haney && make || exit 1
cd ../..
