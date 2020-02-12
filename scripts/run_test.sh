#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

while getopts t: option
do
  case "${option}" in
  t) TEST=${OPTARG};;
  esac
done

# run from root of project
if [ ! -d "./windows" ]
then
  if  [ -d "../windows" ]
  then
    cd ..
  else
    echo "Please run from the root of the project."
  fi
fi

function start_test {
  local test_name=$1
  local test_command=$2

  appveyor AddTest $test_name -Framework junit -Outcome Running
  local start=`date +%s`
  eval "$({ cerr=$({ cout=$($test_command); cret=$?; } 2>&1; declare -p cout cret >&2); declare -p cerr; } 2>&1)"
  local end=`date +%s`
  cruntime=$((end-start))
}

function end_test {
  local test_name=$1
  if [[ "$bret" -eq 0 ]]; then
    appveyor UpdateTest -Name $test_name -Framework junit -Outcome Passed -Duration $cruntime -StdOut $cout
  else
    appveyor UpdateTest -Name $test_name -Framework junit -Outcome Failed -Duration $cruntime -ErrorMessage "$test_name did not complete successfully" -StdOut $cout -StdErr $cerr
  fi
  # Update-AppveyorTest -Name "Test A" -Framework NUnit -FileName a.exe -Outcome Failed -Duration $cruntime
  # Update-AppveyorTest -Name <string> -Framework <string> -FileName <string>
  #      -Outcome <outcome> { None | Running | Passed | Failed | Ignored | Skipped
  #      | Inconclusive | NotFound |  Cancelled | NotRunnable}] [-Duration <long>
  #      [-ErrorMessage <string>] [-ErrorStackTrace <string>]
  #      [-StdOut <string>] [-StdErr <string>]
}

# echo "** DOS2UNIX"
# git ls-files | xargs dos2unix
# git ls-files '*.sln' '*.bat' | xargs unix2dos
# set -e
# echo "** SALT-LINT"
# git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint
# echo "** YAMLLINT"
# yamllint -s .
# echo "** RUBOCOPY"
# rubocop -d
# echo "** SHELLCHECK"
# shellcheck --version
# git ls-files -- '*.sh' '*.bash' '*.ksh' | xargs shellcheck
# echo "** Linting completed successfully"
case $1 in

  salt-lint)
    start_test $TEST "git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint"
    end_test $TEST
    ;;

  PATTERN_2)
    STATEMENTS
    ;;

  PATTERN_N)
    STATEMENTS
    ;;

  *)
    ;;
esac
