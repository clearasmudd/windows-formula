#!/bin/bash

usage='lint [-l salt-lint | yamllint | rubocop | shellcheck | commitlint | PowerShellScriptAnalyzer | pylint | all ] [-i/I] [-p] [-c/C] [-d] [-f] [-e]'
lint_error=0

if [ ! -d './windows' ]; then
  if [ -d '../windows' ]; then
    cd ..
  else
    echo 'Please run from the root of the project.'
  fi
fi

while getopts iIcCdfl:e option; do
  case "${option}" in
  l) LINT=${OPTARG} ;;
  i) iflag=1 ;;
  I) Iflag=1 ;;
  #c) cflag=1 ;;
  #C) Cflag=1 ;;
  d) dflag=1 ;;
  #f) fflag=1 ;;
  p) pflag=1 ;;
  e) eflag=1 ;;
  esac
done

: "${LINT:=all}"

# -d runs dos2unix
if [ ! -z "$dflag" ]; then
  echo 'DOS2UNIX'
  set +e
  git ls-files | xargs dos2unix
  git ls-files '*.sln' '*.bat' '*.ps1' | xargs unix2dos
  set -e
fi

# Install Requirements if -i or -I
# if -p also install prerequisites
if [ ! -z "$iflag" ] || [ ! -z "$Iflag" ]; then
  #shopt -s globstar
  function install-salt-lint() {
    echo installing salt-lint
    pip install --user salt-lint
  }
  function install-yamllint() {
    echo installing yamllint
    pip install --user yamllint
  }
  function install-rubocop() {
    echo installing rubocop
    gem install rubocop
  }
  function install-shellcheck() {
    echo installing shellcheck
    sudo apt-get remove -y --purge man-db
    sudo apt-get install shellcheck
  }
  function install-commitlint() {
    echo installing commitlint
    if [ ! -z "$pflag" ]; then
      if [ ! $(command -v nodejs) ]; then
        curl -sL https://deb.nodesource.com/setup_12.4 -o nodesource_setup.sh
        sudo bash nodesource_setup.sh
        sudo apt install nodejs
      fi
      nodejs -v
      if [ ! $(command -v npm) ]; then
        sudo apt install npm
      fi
      npm -v
      if [ ! $(dpkg -l build-essential) ]; then
        sudo apt install build-essential
      fi
    fi
    npm i -D @commitlint/config-conventional </dev/null
  }
  function install-PowerShellScriptAnalyzer() {
    echo installing PowerShellScriptAnalyzer
    if [ ! -z "$pflag" ]; then
      if [ ! $(command -v pwsh) ]; then
        # Import the public repository GPG keys
        curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        # Register the Microsoft Ubuntu repository
        sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list
        # Update the list of products
        sudo apt-get update
        # Install PowerShell
        sudo apt-get install -y powershell
      fi
    fi

    pwsh -Command "& {Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted}"
    pwsh -Command "& {Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force}"
  }
  function install-pylint() {
    echo install pylint
    sudo apt-get install -y pylint
  }

  if [ "$LINT" == 'all' ]; then
    install-salt-lint
    install-yamllint
    install-rubocop
    install-shellcheck
    install-commitlint
    install-PowerShellScriptAnalyzer
    install-pylint
  else
    "install-$LINT"
  fi

  # if -i then install only
  if [ ! -z "$iflag" ]; then
    echo "Install only complete."
    exit 0
  fi
fi

# # Create Configuration Files if -c or -C
# case ${LINT} in
# salt-lint)
#   # cat > file1 << EOF
#   # do some commands on "$var1"
#   # and/or "$var2"
#   # EOF
#   ;;

# yamllint) ;;
# rubocop) ;;
# shellcheck) ;;
# commitlint) ;;
# PowerShellScriptAnalyzer) ;;
# pylint) ;;

# esac

function not_available() {
  lint_case=$1
  echo "** $lint_case is not available."
  echo -e "\n$usage"
  exit 1
}

function check_and_run() {
  lint_case=$1
  lint_command=$2
  if [ "$lint_case" == "$LINT" ] || [ "$LINT" == 'all' ]; then
    if [[ "${lint_command,,}" == *'npx'* ]]; then
      npx "$lint_case" -v >/dev/null
    else
      command -v "$lint_case" >/dev/null
    fi
    if [ $? -eq 0 ]; then
      echo -e "+"$lint_command'\n'
      eval "$lint_command"
      lint_exit_code=$?
      if [ ! $lint_exit_code -eq 0 ]; then
        lint_error=$lint_exit_code
        echo -e "$lint_case found issues. exit code: $lint_error\n"
        if [ ! -z "$eflag" ]; then
          echo "-e option selected, exiting after first error"
          exit $lint_error
        fi
      fi
    else
      not_available "$lint_case"
    fi
  fi
}

# Run Lint
check_and_run 'salt-lint' "git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint"
check_and_run 'yamllint' 'yamllint -s .'
check_and_run 'rubocop' 'rubocop -d -E'
check_and_run 'shellcheck' "git ls-files *.sh *.bash *.ksh | xargs shellcheck"
check_and_run 'commitlint' 'npx commitlint --from=HEAD~1'
check_and_run 'pylint' "git ls-files -- '*.py' | xargs pylint"

if [ "PowerShellScriptAnalyzer" == "$LINT" ] || [ 'all' == "$LINT" ]; then
  lint_case='PowerShellScriptAnalyzer'
  pwsh -command "./scripts/appveyor_tools.ps1 -function check-if-exists -command Invoke-ScriptAnalyzer"
  if [ $? -eq 0 ]; then
    echo "** $lint_case"
    pwsh -Command "& {Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse -ReportSummary -Settings ./PSScriptAnalyzerSettings.psd1 |
        Format-Table -Wrap -GroupBy ScriptName -autosize -Property @{ e='Line'; width = 4},
        @{ e='Severity'},
        @{ e='RuleName'; width = 10},
        @{ e='Message'} |
        Out-String -Width 130}"
    # @{ e='ScriptName'; width = 15},
  else
    not_available "$lint_case"
  fi
fi

if [ $lint_error -eq 0 ]; then
  echo "No issues found."
fi
exit $lint_error
