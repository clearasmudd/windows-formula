# -*- coding: utf-8 -*-
# vim: ft=sls

{# another comment #}
{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import windows with context %}

include:
  - {{ sls_config_clean }}

windows-package-clean-pkg-removed:
  pkg.removed:
    - name: {{ windows.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
