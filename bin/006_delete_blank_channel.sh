#!/bin/bash
set -e

cd tmp
grep -F -l '"messages": [],' *  | xargs rm
