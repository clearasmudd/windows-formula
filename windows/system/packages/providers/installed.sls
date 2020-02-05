# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.packages.providers %}
{%- if windows.system.enabled and local.enabled %}

{% if local.installed is iterable %}
  {% for provider, context in local.installed.items() %}
windows.system.packages.providers.installed.{{ provider }}:
  cmd.run:
    - name: Get-PackageProvider -Name {{ provider }} -ForceBootstrap
    - shell: powershell
    - onlyif: if ((Get-PackageProvider -Name {{ provider }} -ErrorAction SilentlyContinue) -ne $null) {exit 1}
  {% endfor %}
{% endif %}