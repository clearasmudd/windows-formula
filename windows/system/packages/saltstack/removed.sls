# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "windows/map.jinja" import windows with context %}
{%- for package, args in windows.system.packages.saltstack.installed.items() %}
{{ package }}:
  pkg.removed
{%- endfor %}