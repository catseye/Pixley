#!/bin/sh

# A wrapper script around miniscm (my fork) to get it to behave more or less
# how we want.

miniscm -q -e <$1
