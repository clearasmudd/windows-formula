# -*- coding: utf-8 -*-
# vim: ft=sls
#  c:\salt\salt-call.bat  --state-output=changes --config-dir=C:\Users\vagrant\AppData\Local\Temp\kitchen\etc\salt state.apply windows.clean --retcode-passthrough
{%- if grains['kernel'] == 'Windows'%} 
  {%- from "windows/map.jinja" import windows with context %}
  {%- if windows is defined %}
include:
    {%- if windows.system is defined%} 
  - .system.clean
    {%- endif %}
  {%- endif %}
{%- endif %}