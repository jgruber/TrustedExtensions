#!/bin/bash
buildstring=$(cat lx.spec|grep Release:|cut -d ' ' -f2)
buildint=$(echo $buildstring|sed 's/^0*//')
nextbuildint="$((buildint + 1))"
printf -v nextbuildstring "%04d" $nextbuildint
IS_LINUX=$(uname -o | grep inux | wc -l)
if [ $IS_LINUX == 1 ]; then
    echo "running linux sed"
    sed -i "s/^Release: .*/Release: $nextbuildstring/" lx.spec
else
    echo "running non Linux sed"
    sed -i '' "s/^Release: .*/Release: $nextbuildstring/" lx.spec
fi
echo "Creating build $nextbuildstring"
