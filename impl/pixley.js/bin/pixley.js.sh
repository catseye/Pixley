#!/bin/sh

cp src/pixley.js driver.js
echo -n >>driver.js "var program='"
echo -n >>driver.js $1
echo >>driver.js "';"

cat >>driver.js <<EOF

var result = runPixley(program);
console.log(depict(result));

EOF
node driver.js
rm -f driver.js
