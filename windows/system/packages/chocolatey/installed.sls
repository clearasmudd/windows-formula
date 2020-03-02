# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "windows/map.jinja" import windows with context %}
{%- if windows.system.enabled and windows.system.packages.chocolatey.enabled %}
include:
  - .bootstrap
  {%- if windows.system.packages.chocolatey.installed is iterable %}
    {%- for package, args in windows.system.packages.chocolatey.installed.items() %}
windows.system.packages.chocolatey.{{ package }}:
  chocolatey.installed:
    - require:
      - chocolatey.bootstrap
    - name: {{ package }}
      {%- if args is iterable %}
        {%- for arg in args %}
          {%- if not (((arg == "version") and windows.system.packages.ignore_package_version)) %}
    - {{ arg }}: {{ args['%s'| format(arg)] }}
          {%- endif %}
        {%- endfor %}
      {%- endif %}
    {% endfor %}
  {%- endif %}
{%- endif %}