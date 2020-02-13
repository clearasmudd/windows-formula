#!/bin/bash
# need to wrap commands with pipes for appveyor_tests.sh
git ls-files -- '*.sls' '*.jinja' '*.j2' '*.tmpl' '*.tst' | xargs salt-lint