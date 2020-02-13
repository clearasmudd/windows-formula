#!/bin/bash
# need to wrap commands with pipes for appveyor_tests.sh
git ls-files -- '*.sh' '*.bash' '*.ksh' | xargs shellcheck