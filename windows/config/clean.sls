# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import windows with context %}

include:
  - {{ sls_service_clean }}

windows-config-clean-file-absent:
  file.absent:
    - name: {{ windows.config }}
    - require:
      - sls: {{ sls_service_clean }}
