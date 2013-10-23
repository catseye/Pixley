#!/bin/sh

# scheme-adapter.sh wrapper to support the mignon Pixley implementation

# This is asking Pixley to do Scheme's job, which is of course impossible,
# even on a well-lit night.  So do keep in mind that:

# - the program file (first argument) is just ignored
# - if the expression file (second argument) contains anything other than
#   Pixley, things will crash and burn

impl/mignon/mignon `cat $2` 2>&1
