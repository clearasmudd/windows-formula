# PSScriptAnalyzerSettings.psd1
# https://github.com/PowerShell/PSScriptAnalyzer
@{
    Severity=@('Error','Warning','Information')
    ExcludeRules=@('PSAvoidUsingCmdletAliases') # ,
#                'PSAvoidUsingWriteHost')
}