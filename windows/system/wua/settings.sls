# -*- coding: utf-8 -*-
# vim: ft=sls
# settings need to be changed using group policies for windows 10 +
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.windows_updates.settings %}
{%- if windows.system.enabled and local.enabled is defined and local.enabled %}
windows.system.windows_updates.settings:
  module.run:
    - win_wua.set_wu_settings:
      - level: 4
      - recommended: true
      - featured: false
      - elevated: true
      - msupdate: true
      - day: Everyday
      - time: "01:00"
{%- endif %}
{#
windows.system.windows_updates.settings:
  module.run:
    - win_wua.set_wu_settings:
  {%- if local is iterable %}
    {%- for key, value in local.items() %}
      {%- if  key != "enabled" and key != "time" %}
      - {{ key }}: {{ value }}
      {%- elif key == "time" %}
      - {{ key }}: "{{ value }}"
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endif %}



    {%- if local is iterable %}
    {%- for key, value in local.items() %}
      {%- if  key != "enabled" and key != "time" %}
      - {{ key }}: {{ value }}
      {%- elif key == "time" %}
      - {{ key }}: "{{ value }}"
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endif %}
#}