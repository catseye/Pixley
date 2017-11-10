#!/bin/sh

(cd ../../eg/ && make-files-jsonp --varname=examplePrograms \
                 cons-test.pix \
                 equality-test.pix \
                 list-test.pix \
                 binding-test-1.pix \
                 binding-test-2.pix \
                 binding-test-3.pix \
                 cond-test-1.pix \
                 cond-test-2.pix \
                 lambda-test.pix ) > demo/examples.js
