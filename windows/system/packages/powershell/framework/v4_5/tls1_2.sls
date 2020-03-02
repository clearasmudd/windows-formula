# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}

# https://docs.microsoft.com/en-us/security/solving-tls1-problem
# https://blog.pauby.com/post/force-powershell-to-use-tls-1-2/
# reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:64
# reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:32
# powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"

windows.system.packages.powershell.framework.v4_5.tls1_2.systemdefaulttlsversions_32:
  reg.present:
    - name: HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319
    - vname: SystemDefaultTlsVersions
    - vdata: 1
    - vtype: REG_DWORD
    - use_32bit_registry: true
    - onlyif: powershell -command "if ([Enum]::GetNames([Net.SecurityProtocolType]) -contains 'Tls12') {exit 0} else {exit 1}"

windows.system.packages.powershell.framework.v4_5.tls1_2.systemdefaulttlsversions_64:
  reg.present:
    - name: HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319
    - vname: SystemDefaultTlsVersions
    - vdata: 1
    - vtype: REG_DWORD
    - require:
      - windows.system.packages.powershell.framework.v4_5.tls1_2.systemdefaulttlsversions_32
    - onlyif: powershell -command "if ([Enum]::GetNames([Net.SecurityProtocolType]) -contains 'Tls12') {exit 0} else {exit 1}