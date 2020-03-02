# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.computer %}
{%- if local.enabled %}
  {%- if local.description is defined %}
windows.system.computer.description.{{ windows.system.computer.description }}:
  module.run:
    - system.computer_desc:
      - name: {{ local.description }}
# windows.system.computer.description.{{ windows.system.computer.description }}:
#   module.run:
#     - system.set_computer_desc:
#       - desc: {{ local.description }}
#     - onlyif: powershell -command "if ((Get-WmiObject -Class Win32_OperatingSystem | Select Description -ExpandProperty description) -eq '{{ windows.system.computer.description }}') {exit 1} else {exit 0}"
  {%- endif %}
{% endif %}