# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.computer %}
{%- if local.enabled %}
  {%- if local.hostname is defined %}
windows.system.computer.hostname.{{ windows.system.computer.hostname }}:
  module.run:
    - system.set_computer_name:
      - name: {{ local.hostname }}
    - onlyif: powershell -command "if ([System.Net.Dns]::GetHostName() -eq '{{ windows.system.computer.hostname }}') {exit 1} else {exit 0}"
  {%- endif %}
{% endif %}