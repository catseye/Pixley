#!/bin/sh

cd impl/mignon && make || exit 1
cd ../..
cd impl/haney && make || exit 1
cd ../..
