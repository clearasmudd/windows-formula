#!/bin/bash
# https://www.appveyor.com/docs/build-worker-api/

usage='appveyor_tests [-t salt-lint | yamllint | rubocop | shellcheck | commitlint] [-i]'
if [ $# -eq 0 ]
  then
    echo $usage
    exit 1
fi

if [ ! -d './windows' ]
then
  if  [ -d '../windows' ]
  then
    cd ..
  else
    echo 'Please run from the root of the project or the scripts directory.'
    exit 1
  fi
fi

declare -A APPVEYOR_TEST
APPVEYOR_TEST[framework]=junit
dqt='"'

while getopts t:i option
do
  case "${option}" in
  t) tflag=1;APPVEYOR_TEST[name]=${OPTARG};;
  i) iflag=1;;
  esac
done

function start_test {
  : "${APPVEYOR_TEST[filename]:=APPVEYOR_TEST[name]}"
  add_test="appveyor AddTest ${APPVEYOR_TEST[name]} -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Outcome Running"
  # echo $add_test
  $add_test
  local start=`date +%s`
  echo "${APPVEYOR_TEST[command]}"
  eval "$({ cerr=$({ cout=$(${APPVEYOR_TEST[command]}); cret=$?; } 2>&1; declare -p cout cret >&2); declare -p cerr; } 2>&1)"
  local end=`date +%s`
  APPVEYOR_TEST[cruntime]=$((end-start))
  APPVEYOR_TEST[cret]="${cret:-''}"
  APPVEYOR_TEST[cout]="${cout:-''}"
  APPVEYOR_TEST[cerr]="${cerr:-''}"
  echo "${APPVEYOR_TEST[name]} finished in ${APPVEYOR_TEST[cruntime]} with return code: ${APPVEYOR_TEST[cret]}"
}

# Update-AppveyorTest -Name "Test A" -Framework NUnit -FileName a.exe -Outcome Failed -Duration $cruntime
# Update-AppveyorTest -Name <string> -Framework <string> -FileName <string>
#      -Outcome <outcome> { None | Running | Passed | Failed | Ignored | Skipped
#      | Inconclusive | NotFound |  Cancelled | NotRunnable}] [-Duration <long>
#      [-ErrorMessage <string>] [-ErrorStackTrace <string>]
#      [-StdOut <string>] [-StdErr <string>]

function end_test {
  # update_test_common="appveyor UpdateTest -Name ${APPVEYOR_TEST[name]} -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Duration ${APPVEYOR_TEST[cruntime]}"
  if [[ ${APPVEYOR_TEST[cret]} -eq 0 ]]; then
    echo "${APPVEYOR_TEST[name]} completed successfully!"
    # updatetest="appveyor UpdateTest -Name ${APPVEYOR_TEST[name]} -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Duration ${APPVEYOR_TEST[cruntime]} -Outcome Passed ${APPVEYOR_TEST[cout_arg]}"
    appveyor UpdateTest -Name "${APPVEYOR_TEST[name]}" -Framework "${APPVEYOR_TEST[framework]}" -Filename "${APPVEYOR_TEST[filename]}" -Duration "${APPVEYOR_TEST[cruntime]}" -Outcome Passed -StdOut "${APPVEYOR_TEST[cout]}"
  else
    echo "${APPVEYOR_TEST[name]} did not complete successfully!  Check the 'Tests' tab in appveyor for additional information."
    # updatetest="appveyor UpdateTest -Name ${APPVEYOR_TEST[name]} -Framework ${APPVEYOR_TEST[framework]} -Filename ${APPVEYOR_TEST[filename]} -Duration ${APPVEYOR_TEST[cruntime]} -Outcome Failed -ErrorMessage ${dqt}${APPVEYOR_TEST[name]} return code: ${APPVEYOR_TEST[cret_arg]}${dqt} ${APPVEYOR_TEST[cout_arg]} ${APPVEYOR_TEST[cerr_arg]}"
    appveyor UpdateTest -Name "${APPVEYOR_TEST[name]}" -Framework "${APPVEYOR_TEST[framework]}" -Filename "${APPVEYOR_TEST[filename]}" -Duration "${APPVEYOR_TEST[cruntime]}" -Outcome Failed -ErrorMessage "${APPVEYOR_TEST[name]} return code: ${APPVEYOR_TEST[cret]}" -StdOut "${APPVEYOR_TEST[cout]}" -StdErr "${APPVEYOR_TEST[cerr]}"
    exit ${APPVEYOR_TEST[cret]}
  fi
  # echo $updatetest
  # $updatetest
}

if [ ! -z "$iflag" ]; then
    echo 'Installing linting tools'
    pip install --user salt-lint
    pip install --user yamllint>=1.17.0
    gem install rubocop
    sudo apt-get install shellcheck
    shellcheck --version
    npm i -D @commitlint/config-conventional
fi

if [ ! -z "$tflag" ]; then
  echo "Running ${APPVEYOR_TEST[name]}"
fi

case ${APPVEYOR_TEST[name]} in

  salt-lint)
    # echo "in salt-lint"
    APPVEYOR_TEST[filename]='*.sls *.jinja *.j2 *.tmpl *.tst'
    APPVEYOR_TEST[command]="git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint"
    start_test
    end_test
    ;;

  yamllint)
    APPVEYOR_TEST[filename]='*.yml *.yaml'
    APPVEYOR_TEST[command]='yamllint -s .'
    start_test
    end_test
    ;;

  rubocop)
    APPVEYOR_TEST[filename]='*.rb and files starting with #!/usr/bin/env ruby'
    APPVEYOR_TEST[command]='rubocop -d -E'
    start_test
    end_test
    ;;

  shellcheck)
    APPVEYOR_TEST[filename]='*.sh *.bash *.ksh'
    APPVEYOR_TEST[command]="git ls-files -- '*.sh' '*.bash' '*.ksh' | xargs shellcheck"
    start_test
    end_test
    ;;

  commitlint)
    APPVEYOR_TEST[filename]='git commit message'
    APPVEYOR_TEST[command]='npx commitlint --from=HEAD~1'
    start_test
    end_test
    ;;

  # *)
  #   echo $usage
  #   ;;
esac
