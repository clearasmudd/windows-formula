# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.packages.powershell.modules %}
{%- if windows.system.enabled and local.enabled %}

{% if local.installed is iterable %}
  {% for module, context in local.installed.items() %}
windows.system.packages.powershell.modules.installed.{{ module }}:
  cmd.run:
    - name: Install-Module -Name {{ module }} -Force
    - shell: powershell
    - onlyif: if ((Get-InstalledModule | where Name -eq {{ module }}) -ne $null) {exit 1}
  {% endfor %}
{% endif %}