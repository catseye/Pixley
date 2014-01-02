#!/bin/sh

# scheme-adapter.sh wrapper to support the pixley.js Pixley implementation

# This is asking Pixley to do Scheme's job, which is of course impossible,
# even on a well-lit night.  So do keep in mind that:

# - the program file (first argument) is just ignored
# - if the expression file (second argument) contains anything other than
#   Pixley, things will crash and burn

cp impl/pixley.js/src/pixley.js driver.js
echo -n >>driver.js "var program='"
echo -n >>driver.js `tr -d '\n' <$2`
echo >>driver.js "';"

cat >>driver.js <<EOF
var result = runPixley(program);
console.log(depict(result));
EOF

if [ ! "${DEBUG}x" = "x" ]; then
    less driver.js
fi

node driver.js
rm -f driver.js
