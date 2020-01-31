#!/bin/bash
echo "SALT-LINT"
git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint
echo "YAMLLINT"
yamllint -s .
echo "RUBOCOPY"
rubocop -d
echo "SHELLCHECK"
shellcheck --version