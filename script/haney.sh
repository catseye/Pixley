#!/bin/sh

# scheme-adapter.sh wrapper to support the haney Pixley implementation

# This is asking Pixley to do Scheme's job, which is of course impossible,
# even on a well-lit night.  So do keep in mind that:

# - the program file (first argument) is just ignored
# - if the expression file (second argument) contains anything other than
#   Pixley, things will crash and burn

if [ ! "${DEBUG}x" = "x" ]; then
    less $2
fi

impl/haney/haney $2 2>&1
