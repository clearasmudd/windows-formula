#!/bin/bash
pwsh -Command "& {Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse -Settings ./PSScriptAnalyzerSettings.psd1 | ft --AutoSize}"