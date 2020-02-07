#!/bin/bash
# exit when any command fails

git diff-index --quiet HEAD -- || { echo "Exiting, you have uncommitted git changes."; git status; exit 1; } 

./lint.sh
set +e
echo "** Removing the following test kitchen results:"
find test/results/ -type f -iregex '.*[json|txt|xml|log]'
find test/results/ -type f -iregex '.*[json|txt|xml|log]' -delete

echo "** Starting kitchen test"
for SERVER in $(kitchen list | awk '{if(NR>1)print $1}')
do
  my_log="test/results/$SERVER.log"
  if [[ $SERVER == *"windows-10-1903"* ]]; then
    date | tee $my_log
    set -ex
    git log HEAD~2..HEAD | tee -a $my_log
    git status | tee -a $my_log
    kitchen test $SERVER -l info | tee -a $my_log
  fi
  # git add test/results/*
  # git commit -m "test(kitchen): run local test kitchen."
  read -p 'Commit test results and push to github? [y]' -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    git add -A test/results
    git commit -m "test(local): local 'kitchen test' results"
    git push
  else 
    echo "git add test/results/*"
    echo "git commit -m \"test(local): local 'kitchen test' results\""
    echo "git push"
  fi
done