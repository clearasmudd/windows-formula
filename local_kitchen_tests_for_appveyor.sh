#!/bin/bash
# exit when any command fails

echo "** Removing the following test kitchen results:"
find test/results/ -type f -iregex '.*[json|txt|xml|log]'
find test/results/ -type f -iregex '.*[json|txt|xml|log]' -delete
./lint.sh

set -e

echo "** Running test kitchen against Windows 10 locally"
for SERVER in $(kitchen list | awk '{if(NR>1)print $1}')
do
  my_log="test/results/$SERVER.log"
  if [[ $SERVER == *"windows-10-1903"* ]]; then
    date | tee $my_log
    echo "** git log HEAD~3..HEAD" | tee -a $my_log
    git log HEAD~3..HEAD | tee -a $my_log
    echo "** git status:" | tee -a $my_log
    git status | tee -a $my_log
    echo "** unning test kitchen against $SERVER." | tee -a $my_log
    kitchen test $SERVER -l info | tee -a $my_log
    echo "** git status:" | tee -a $my_log
    git status | tee -a $my_log
  fi
  # git add test/results/*
  # git commit -m "test(kitchen): run local test kitchen."
  echo "** verify and then: "
  echo "git add test/results/*"
  echo "git commit -m 'test(kitchen): run lint and local test kitchen for Windows 10 hosts'"
done