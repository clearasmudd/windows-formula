#!/bin/bash
# shellcheck disable=SC2031
# https://www.appveyor.com/docs/build-worker-api/

usage='appveyor_tools [-f sysinfo | test | lint] [-t salt-lint | yamllint | rubocop | shellcheck | commitlint | PowerShellScriptAnalyzer] [-i] [-l powershell | salt-lint | shellcheck]'
if [ $# -eq 0 ]; then
  echo "$usage"
  exit 1
fi

if [ ! -d './windows' ]; then
  if [ -d '../windows' ]; then
    cd ..
  else
    echo 'Please run from the root of the project or the scripts directory.'
    exit 1
  fi
fi

declare -A APPVEYOR_TEST
APPVEYOR_TEST[framework]=junit
sysinfo_filename=${env_sysinfo_filename:="/tmp/sysinfo.txt"}

shopt -s globstar
command -v appveyor
if [ ! $? -eq 0 ]; then
  echo "appveyor is not installed, commands will only be echoed"
  shopt -s expand_aliases
  alias appveyor='echo'
fi

while getopts f:t:l:i option; do
  case "${option}" in
  f) FUNCTION=${OPTARG} ;;
  t)
    tflag=1
    APPVEYOR_TEST[name]=${OPTARG}
    ;;
  l) LINT=${OPTARG} ;;
  i) iflag=1 ;;
  esac
done

function appveyor_message() {
  info=$($1)
  # if [ $(echo $info | wc -l) < 30 ]; then
  echo "working on $1"
  appveyor AddMessage "$1" -Category "Information" -Details "$(echo "$info" 2>/dev/null | head -40)"
  echo "system information ($1):" >>$sysinfo_filename
  echo "$info" >>$sysinfo_filename
  # Add-AppveyorMessage -Message <string>
  #   [-Category <category> {Information | Warning | Error}]
  #   [-Details <string>]
}

case "${FUNCTION}" in
test)
  function run_test() {
    : "${APPVEYOR_TEST[filename]:=APPVEYOR_TEST[name]}"
    appveyor AddTest "${APPVEYOR_TEST[name]}" -Framework "${APPVEYOR_TEST[framework]}" -Filename "${APPVEYOR_TEST[filename]}" -Outcome Running
    local ts
    # ts=$(date +%s%N) ; $@ ; tt=$((($(date +%s%N) - $ts)/1000000)) ; echo "Time taken: $tt milliseconds"
    echo "${APPVEYOR_TEST[command]}"
    ts=$(date +%s%N)
    # shellcheck disable=SC2030
    eval "$({
      cerr=$(
        {
          cout=$(${APPVEYOR_TEST[command]})
          cret=$?
        } 2>&1
        declare -p cout cret >&2
      )
      declare -p cerr
    } 2>&1)"
    APPVEYOR_TEST[cruntime]=$((($(date +%s%N) - ts) / 1000000))
    APPVEYOR_TEST[cruntimesec]=$(echo "scale=4;${APPVEYOR_TEST[cruntime]}/1000" | bc)
    # end=$(date +%s)
    # command substitution strips newline echo -n "$(echo -n 'a\nb')" vs echo -n  $(echo -n 'a\nb')
    echo "$cout"
    echo "$cerr"
    # APPVEYOR_TEST[cruntime]=$((end-start))
    APPVEYOR_TEST[cret]=$cret
    APPVEYOR_TEST[cout]="$cout"
    APPVEYOR_TEST[cerr]="$cerr"
  }

  # Update-AppveyorTest -Name "Test A" -Framework NUnit -FileName a.exe -Outcome Failed -Duration $cruntime
  # Update-AppveyorTest -Name <string> -Framework <string> -FileName <string>
  #      -Outcome <outcome> { None | Running | Passed | Failed | Ignored | Skipped
  #      | Inconclusive | NotFound |  Cancelled | NotRunnable}] [-Duration <long>
  #      [-ErrorMessage <string>] [-ErrorStackTrace <string>]
  #      [-StdOut <string>] [-StdErr <string>]

  function end_test() {
    if [[ ${APPVEYOR_TEST[cret]} -eq 0 ]]; then
      APPVEYOR_TEST[cout]=$(echo "${APPVEYOR_TEST[cout]}" | sed '/No issues found./d' | sed '/^\+/d')
      echo "${APPVEYOR_TEST[name]} ran for ${APPVEYOR_TEST[cruntimesec]} milliseconds and completed successfully with return code: ${APPVEYOR_TEST[cret]}!"
      appveyor UpdateTest -Name "${APPVEYOR_TEST[name]}" -Framework "${APPVEYOR_TEST[framework]}" -Filename "${APPVEYOR_TEST[filename]}" -Duration "${APPVEYOR_TEST[cruntime]}" -Outcome Passed -StdOut "${APPVEYOR_TEST[cout]}"
    else
      echo "${APPVEYOR_TEST[name]} ran for ${APPVEYOR_TEST[cruntimesec]} milliseconds and did not complete successfully with return code: ${APPVEYOR_TEST[cret]}!"
      echo "Check the 'Tests' tab in appveyor for additional information."
      appveyor UpdateTest -Name "${APPVEYOR_TEST[name]}" -Framework "${APPVEYOR_TEST[framework]}" -Filename "${APPVEYOR_TEST[filename]}" -Duration "${APPVEYOR_TEST[cruntime]}" -Outcome Failed -ErrorMessage "return code: ${APPVEYOR_TEST[cret]}" -StdOut "${APPVEYOR_TEST[cout]}" -StdErr "${APPVEYOR_TEST[cerr]}"
    fi
  }

  if [ ! -z "$iflag" ]; then
    echo 'Installing linting tools'
    sudo apt-get install bc -y
    #sudo apt-get remove -y --purge man-db
    #pip install --user salt-lint
    #pip install --user yamllint
    #gem install rubocop
    #npm i -D @commitlint/config-conventional </dev/null
    #sudo apt-get install shellcheck
    #shellcheck --version
    #pwsh -Command "& {Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted}"
    #pwsh -Command "& {Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force}"
    #sudo apt-get install pylint
    shopt -s globstar
    ./scripts/lint.sh -l all -i -p
  fi

  if [ ! -z "$tflag" ]; then
    echo "Running ${APPVEYOR_TEST[name]}"
  fi

  case ${APPVEYOR_TEST[name]} in
  salt-lint)
    # echo "in salt-lint"
    APPVEYOR_TEST[filename]='*.sls *.jinja *.j2 *.tmpl *.tst'
    # APPVEYOR_TEST[command]='salt-lint ./**/+(*.sls|*.jinja|*.j2|&.tmpl|*.tst)'
    APPVEYOR_TEST[command]="./scripts/lint.sh -l salt-lint"
    run_test
    APPVEYOR_TEST[cout]=$(echo "${APPVEYOR_TEST[cout]}" | sed '/Examining/d')
    end_test
    ;;

  yamllint)
    APPVEYOR_TEST[filename]='*.yml *.yaml'
    APPVEYOR_TEST[command]="./scripts/lint.sh -l yamllint"
    #APPVEYOR_TEST[command]='yamllint -s .'
    run_test
    end_test
    ;;

  rubocop)
    APPVEYOR_TEST[filename]="*.rb and '#!/usr/bin/env ruby'"
    APPVEYOR_TEST[command]="./scripts/lint.sh -l rubocop"
    #APPVEYOR_TEST[command]='rubocop -d -E'
    run_test
    end_test
    ;;

  shellcheck)
    APPVEYOR_TEST[filename]='*.sh *.bash *.ksh'
    # APPVEYOR_TEST[command]="git ls-files *.sh *.bash *.ksh | xargs shellcheck"
    # APPVEYOR_TEST[command]='shellcheck ./**/+(*.sh|*.bash|*.ksh)'
    APPVEYOR_TEST[command]="./scripts/lint.sh -l shellcheck"
    #APPVEYOR_TEST[command]="./scripts/appveyor_tools.sh -f lint -l shellcheck"
    run_test
    end_test
    ;;

  commitlint)
    APPVEYOR_TEST[filename]='git commit message'
    APPVEYOR_TEST[command]="./scripts/lint.sh -l commitlint"
    #APPVEYOR_TEST[command]='npx commitlint --from=HEAD~1'
    run_test
    if [[ "${APPVEYOR_TEST[cret]}" != "0" ]]; then
      APPVEYOR_TEST[cout]+=$'\n'$'\n''GIT COMMIT:'$'\n'"$(git log -1)"
    fi
    end_test
    ;;

  pylint)
    APPVEYOR_TEST[filename]='*.py'
    # APPVEYOR_TEST[command]='pylint ./**/+(*.py)'
    APPVEYOR_TEST[command]="./scripts/lint.sh -l pylint"
    #APPVEYOR_TEST[command]='./scripts/appveyor_tools.sh -f lint -l pylint'
    run_test
    end_test
    ;;

  powershell-script-analyzer)
    APPVEYOR_TEST[filename]='*.ps*'
    APPVEYOR_TEST[command]="./scripts/lint.sh -l PowerShellScriptAnalyzer"
    #APPVEYOR_TEST[command]="./scripts/appveyor_tools.sh -f lint -l powershell"
    run_test
    if [[ ! "${APPVEYOR_TEST[cout]}" == *"0 rule violations found"* ]]; then
      APPVEYOR_TEST[cret]=1
    fi
    end_test
    ;;

    # *)
    #   echo $usage
    #   ;;
  esac
  echo "${APPVEYOR_TEST[cret]}"
  # shellcheck disable=SC2086
  exit ${APPVEYOR_TEST[cret]}
  ;;

get-sysinfo)
  # set -x
  echo "Gathering System Information..."
  echo "  - Truncated output will be available in the Appveyor Messages Tab"
  echo "  - The full content will be output at the end of the build process"
  sysinfo_filename="/tmp/sysinfo.txt"
  appveyor_message "date"
  appveyor_message "uptime"
  appveyor_message "/bin/uname -a"
  appveyor_message "cat /proc/version"
  appveyor_message "echo Terminal Dimensions: \"$(tput cols)\" columns x \"$(tput lines)\" rows"
  appveyor_message "sudo lshw"
  appveyor_message "pwd"
  appveyor_message "ls -la"
  appveyor_message "cat /etc/*-release"
  appveyor_message "bash --version"
  appveyor_message "printenv"
  appveyor_message "route -n"
  appveyor_message "grep -v '#' < /etc/fstab"
  appveyor_message "df -h"
  appveyor_message "ps -ef"
  appveyor_message "sudo dpkg-query -l"
  # /usr/bin/pwsh
  appveyor_message 'pwsh -Command "& {Get-Module -ListAvailable}"'

  ;;

output-sysinfo)
  # if [ ! -f "$sysinfo_filename" ]; then
  #   ./scripts/appveyor_tools.sh -f get-sysinfo
  # fi

  if [ -f "$sysinfo_filename" ]; then
    cat $sysinfo_filename
  else
    echo "unable to get sysinfo"
  fi
  ;;

lint)
  # need to wrap commands with pipes for appveyor_tests.sh
  case "${LINT}" in
  powershell)
    # https://github.com/PowerShell/PSScriptAnalyzer
    pwsh -Command "& {Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse -ReportSummary -Settings ./PSScriptAnalyzerSettings.psd1 |
        Format-Table -Wrap -GroupBy ScriptName -autosize -Property @{ e='Line'; width = 4},
        @{ e='Severity'},
        @{ e='RuleName'; width = 10},
        @{ e='Message'} |
        Out-String -Width 130}"
    # @{ e='ScriptName'; width = 15},
    ;;

  salt-lint)
    git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint
    ;;

  pylint)
    git ls-files -- '*.py' | xargs pylint
    ;;

  shellcheck)
    git ls-files -- '*.sh' '*.bash' '*.ksh' | xargs shellcheck
    ;;
  esac
  ;;
esac
