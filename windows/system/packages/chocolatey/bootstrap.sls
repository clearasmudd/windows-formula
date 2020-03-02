# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "windows/map.jinja" import windows with context %}
{%- if windows.system.enabled and windows.system.packages.chocolatey.enabled %}
chocolatey.bootstrap:
  module.run:
    - chocolatey.bootstrap:
    - unless: "where.exe chocolatey"
    - require:
      - windows.system.packages.powershell.framework.v4_5.tls1_2.systemdefaulttlsversions_64
{%- endif %}
