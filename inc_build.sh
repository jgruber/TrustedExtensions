#!/bin/bash
buildstring=$(cat lx.spec|grep Release:|cut -d ' ' -f2)
buildint=$(echo $buildstring|sed 's/^0*//')
nextbuildint="$((buildint + 1))"
printf -v nextbuildstring "%04d" $nextbuildint
sed -i "s/^Release: .*/Release: $nextbuildstring/" lx.spec
echo "Creating build $nextbuildstring"
