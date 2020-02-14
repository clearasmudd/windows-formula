#!/bin/bash
# pwsh -Command "& {$a=@{Expression={$_.RuleName}; Label='RuleName'; Width=30}, @{Expression={$_.Severity}; Label='Severity'; Width=30}, @{Expression={$_.ScriptName}; Label='ScriptName'; Width=30}, @{Expression={$_.Line}; Label='Line'; Width=30}, @{Expression={$_.Line}; Label='Line'; Width=30}}"
pwsh -Command "& {Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse -ReportSummary -Settings ./PSScriptAnalyzerSettings.psd1 | `
Format-Table -Wrap -Property @{ e='RuleName'; width = 15}, @{ e='Severity'; width = 11}, `
@{ e='ScriptName'; width = 15}, @{ e='Line'; width = 4}, @{ e='Message'; width = 85} | Out-String -Width 130}"