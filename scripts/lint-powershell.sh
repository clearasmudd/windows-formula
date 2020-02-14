#!/bin/bash
# https://github.com/PowerShell/PSScriptAnalyzer
pwsh -Command "& {Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse -ReportSummary -Settings ./PSScriptAnalyzerSettings.psd1 |
Format-Table -Wrap -GroupBy ScriptName -autosize -Property @{ e='Line'; width = 4},
@{ e='Severity'},
@{ e='RuleName'; width = 10},
@{ e='Message'} |
Out-String -Width 130}"
# @{ e='ScriptName'; width = 15},