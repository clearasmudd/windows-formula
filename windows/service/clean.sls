# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}

windows-service-clean-service-dead:
  service.dead:
    - name: {{ windows.service.name }}
    - enable: False
