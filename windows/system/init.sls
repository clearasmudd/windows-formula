# -*- coding: utf-8 -*-
# vim: ft=sls
# sls: {{ sls }} {{ sls.split('.')[0] }} {{ sls.split('.')[-1] }}
# slspath: {{ slspath }} {{ slspath.split('/')[0] }} {{ slspath.split('/')[-1] }}
# sls: os_windows.desktop.features os_windows features
# slspath: os_windows/desktop os_windows desktop
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system %}
{%- if local.enabled %}
{%- endif %}
include:
  # - .settings
  # {%- if local.dsc is defined %}
  # - .dsc
  # {%- endif %}
  {%- if local.packages is defined %}
  - .packages
  {%- endif %}
  {%- if local.server is defined %}
  - .server
  {%- endif %}
  {%- if local.desktop is defined %}
  - .desktop
  {%- endif %}

{#
include:
{% for item in local | reject("eq","enabled") %}
  {% if item.enabled is defined %}
    {% set path = tplroot + "/" + slspath + "/" + item %}
    {% if salt['file.directory_exists'](path) or salt['file.file_exists'](path + ".sls") %}
    - .{{ item }}
    {%- endif %}
  {%- endif %}
{%- endfor %}
#}