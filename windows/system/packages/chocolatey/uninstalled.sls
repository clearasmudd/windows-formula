# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "windows/map.jinja" import windows with context %}
{%- for package, args in windows.system.packages.chocolatey.installed.items() %}
windows.system.packages.chocolatey.{{ package }}:
  chocolatey.uninstalled:
    - require:
      - chocolatey.bootstrap
    - name: {{ package }}
{%- endfor %}
