#!/bin/bash
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
echo "** DOS2UNIX"
git ls-files | xargs dos2unix
git ls-files '*.sln' '*.bat' | xargs unix2dos
set -e
echo "** SALT-LINT"
git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint
echo "** YAMLLINT"
yamllint -s .
echo "** RUBOCOPY"
rubocop -d
echo "** SHELLCHECK"
shellcheck --version
git ls-files -- '*.sh' '*.bash' '*.ksh' | xargs shellcheck
echo "** PowerShell Script Analyzer"
pwsh -Command "& {Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse -Settings ./PSScriptAnalyzerSettings.psd1}"
echo "** Linting completed successfully"