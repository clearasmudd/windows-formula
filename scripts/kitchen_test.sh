#!/bin/bash
shopt -s globstar
declare -A failures

if [ ! -d './windows' ]; then
  if [ -d '../windows' ]; then
    cd ..
  else
    echo 'Please run from the root of the project or the scripts directory.'
    exit 1
  fi
fi

while getopts s:d:l option; do
  case "${option}" in
  s)
    to_test=${OPTARG}
    ;;
  d)
    delete_logs=${OPTARG}
    ;;
  l)
    lflag=1
    ;;
  esac
done

: "${to_test:=all}"
: "${delete_logs:=true}"

if [ ! -z "$lflag" ]; then
  ./scripts/lint.sh -l all -e
fi

echo "Removing old test kitchen results"
if [ "$to_test" == 'all' ] && [ "$delete_logs" == 'true' ]; then
  find test/results/ -type f -iregex '.*[json|txt|xml|log]'
  find test/results/ -type f -iregex '.*[json|txt|xml|log]' -delete
fi

function log_test_kitchen_test() {
  SERVER=$1
  my_log="test/results/$SERVER.log"
  my_debug_log="test/results/$SERVER.kitchen.log"
  kitchen_log=".kitchen/logs/$SERVER.log"
  salt_log_target="test/results/$SERVER.salt.log"
  if [[ $SERVER == *"windows"* ]]; then
    if [ -f "$salt_log_source" ]; then rm -f "$salt_log_source"; fi
    set -ex
    date | tee "$my_log"
    git log HEAD~1..HEAD | tee -a "$my_log"
    echo "CURRENT BRANCH COMMIT ID" | tee -a "$my_log"
    git rev-parse HEAD | tee -a "$my_log"
    echo "CURRENT RELEASE TAG" | tee -a "$my_log"
    git tag --sort=committerdate | tail -1 | tee -a "$my_log"
    kitchen test "$SERVER" --no-color --destroy always | tee -a "$my_log"
    return_code=${PIPESTATUS[0]}
    if [ ! "$return_code" -eq 0 ]; then
      echo "KITCHEN TEST DID NOT COMPLETE SUCCESSFULLY." | tee -a "$my_log"
    fi
    if [ -f "$kitchen_log" ]; then cp "$kitchen_log" "$my_debug_log"; fi
    if [ -f "$salt_log_source" ]; then mv "$salt_log_source" "$salt_log_target"; fi
    echo "KITCHEN TEST EXIT CODE" | tee -a "$my_log"
    echo "$return_code" | tee -a "$my_log"
  fi
}
wsl_results='/mnt/c/tmp/results'
salt_log_source="$wsl_results/salt_minion_debug.log"
mkdir -p $wsl_results

echo "Getting Platforms:"
if [ ! "$to_test" == 'all' ]; then
  kitchen_platforms=$to_test
else
  kitchen_platforms=$(kitchen list | awk '{if(NR>1)print $1}')
fi
echo "$kitchen_platforms"
echo 'Starting kitchen tests'
for PLATFORM in $kitchen_platforms; do
  log_test_kitchen_test "$PLATFORM"

  if [ $? -ne 0 ]; then
    failures_array["$PLATFORM"]="$?"
  fi
done
if [ ${#failures_array[@]} -eq 0 ]; then
  dos2unix test/results/*
  read -p 'Commit test results and push to github? [y]' -n 1 -r REPLY
  echo
  commit_message="test: on premise windows 10 and windows server 'kitchen test' results [skip ci]"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add -A test/results
    git commit -m "$commit_message"
  else
    echo git add test/results/*
    echo git commit -m "$commit_message"
  fi
else
  for failure in "${!failures[@]}"; do
    echo "ERROR: $failure did not complete successfully: ${failures[$failure]}"
  done
fi
