#!/bin/bash
set -e

cd tmp
#grep -F -l '"messages": [],' *  | xargs rm
find . -size -200c ! -name .gitignore | xargs --no-run-if-empty rm
