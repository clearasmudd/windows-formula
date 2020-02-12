#!/bin/bash
# https://www.appveyor.com/docs/build-worker-api/

if [ $# -eq 0 ]
  then
    echo "appveyor_tests [-t salt-lint | yamllint | rubocop | shellcheck | commitlint] [-i]"
    exit 1
fi

if [ ! -d "./windows" ]
then
  if  [ -d "../windows" ]
  then
    cd ..
  else
    echo "Please run from the root of the project or the scripts directory."
    exit 1
  fi
fi

declare -A APPVEYOR_TEST
APPVEYOR_TEST[framework] = junit

while getopts t: option
do
  case "${option}" in
  t) APPVEYOR_TEST[name]=${OPTARG};;
  i) iflag=1;;
  esac
done

function start_test {
  : "${APPVEYOR_TEST[filename]:=APPVEYOR_TEST[name]}"
  appveyor AddTest ${APPVEYOR_TEST[name]} -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Outcome Running
  local start=`date +%s`
  eval "$({ cerr=$({ cout=$(${APPVEYOR_TEST[command]}); cret=$?; } 2>&1; declare -p cout cret >&2); declare -p cerr; } 2>&1)"
  local end=`date +%s`
  APPVEYOR_TEST[cruntime]=$((end-start))
  APPVEYOR_TEST[cret_arg]="${cret:-''}"
  if [[ -z cout ]]; then APPVEYOR_TEST[cout_arg]="-StdOut $cout"; else cout_arg=''; fi
  if [[ -z cerr ]]; then APPVEYOR_TEST[cerr_arg]="-StdErr $cerr"; else APPVEYOR_TEST[cerr_arg]=''; fi
  echo "cret_arg $cret_arg"
  echo "cout_arg $cout_arg"
  echo "cerr_arg $cerr_arg"
}

# Update-AppveyorTest -Name "Test A" -Framework NUnit -FileName a.exe -Outcome Failed -Duration $cruntime
# Update-AppveyorTest -Name <string> -Framework <string> -FileName <string>
#      -Outcome <outcome> { None | Running | Passed | Failed | Ignored | Skipped
#      | Inconclusive | NotFound |  Cancelled | NotRunnable}] [-Duration <long>
#      [-ErrorMessage <string>] [-ErrorStackTrace <string>]
#      [-StdOut <string>] [-StdErr <string>]

function end_test {
  if [[ APPVEYOR_TEST[cret_arg] -eq 0 ]]; then
    appveyor UpdateTest -Name ${APPVEYOR_TEST[name]} -Outcome Passed -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Duration ${APPVEYOR_TEST[cruntime]} ${APPVEYOR_TEST[cout_arg]}
  else
    appveyor UpdateTest -Name ${APPVEYOR_TEST[name]} -Outcome Failed -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Duration ${APPVEYOR_TEST[cruntime]} -ErrorMessage "${APPVEYOR_TEST[name]} did not complete successfully: ${APPVEYOR_TEST[cret_arg]}" ${APPVEYOR_TEST[cout_arg]} ${APPVEYOR_TEST[cerr_arg]}
  fi
}

if [ ! -z "$iflag" ]; then
    echo "Installing linting tools"
    pip install --user salt-lint
    pip install --user yamllint>=1.17.0
    gem install rubocop
    sudo apt-get install shellcheck
    shellcheck --version
    npm i -D @commitlint/config-conventional
fi

case ${APPVEYOR_TEST[name]} in
  *)
    echo "Running ${APPVEYOR_TEST[name]}"
    ;;

  salt-lint)
    APPVEYOR_TEST[filename]="*.sls *.jinja *.j2 *.tmpl *.tst"
    APPVEYOR_TEST[command]="git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint"
    start_test
    end_test
    ;;

  yamllint)
    APPVEYOR_TEST[filename]="*.yml *.yaml"
    APPVEYOR_TEST[command]="yamllint -s ."
    start_test
    end_test
    ;;

  rubocop)
    APPVEYOR_TEST[filename]="*.rb and files starting with #!/usr/bin/env ruby"
    APPVEYOR_TEST[command]="rubocop -d -E"
    start_test
    end_test
    ;;

  shellcheck)
    APPVEYOR_TEST[filename]="*.sh *.bash *.ksh"
    APPVEYOR_TEST[command]="git ls-files -- '*.sh' '*.bash' '*.ksh' | xargs shellcheck"
    start_test
    end_test
    ;;

  commitlint)
    APPVEYOR_TEST[filename]="git commit message"
    APPVEYOR_TEST[command]="npx commitlint --from=HEAD~1"
    start_test
    end_test
    ;;
esac
