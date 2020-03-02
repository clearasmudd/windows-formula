# -*- coding: utf-8 -*-
# vim: ft=sls
# https://stackoverflow.com/questions/11947325/testing-for-a-list-in-jinja2
# https://groups.google.com/forum/#!topic/salt-users/uNS4D3GSDq4
# https://stackoverflow.com/questions/46915278/jinja-syntax-for-yaml-file
# https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.jinja.html
# https://github.com/saltstack/salt/issues/30454
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.windows_updates.uptodate %}

{%- if windows.system.enabled and local.enabled is defined and local.enabled %}
windows.system.windows_updates.uptodate:
  wua.uptodate:
  {%- if local is iterable %}
    {%- for key, value in local.items() %}
      {%- if key != "enabled" and value is not iterable %}
    - {{ key }}: {{ value }}
      {%- elif value is iterable %}
    - {{ key }}:
        {%- for item in value %}
            - {{ item }}
        {%- endfor %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{#
windows.system.windows_updates.install_updates_immediately:
  module.run:
    - win_wua.list:
  {%- if local is iterable %}
    {%- for key, value in local.items() %}
      {%- if value is not iterable and value is string and value != "enabled" %}
      - {{ key }}: {{ value }}
      {%- elif value is iterable %}
      - {{ key }}:
        {%- for item in value %}
              - {{ item }}
        {%- endfor %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endif %}

#}


{#
        {%- for item in value %}
        - {{ item | yaml }}
                {%- endfor %}
{% for user, uid in pillar.get('users', {}).items() %}
{{ user }}:
  user.present:
    - uid: {{ uid }}
{% endfor %}



  {%- if local.software is defined %}
      - software: {{ local.software }}
  {%- endif %}
  {%- if local.drivers is defined %}
      - drivers: {{ local.drivers }}
  {%- endif %}
  {%- if local.summary is defined %}
      - summary: {{ local.summary }}
  {%- endif %}
      - skip_installed
  {%- if local.categories is defined %}
      - categories:
    {%- for category in local.categories %}
        - {{ category }}:
    {%- endfor %}
  {%- endif %}
  {%- if local.severities is defined %}
      - severities:
    {%- for severity in local.severities %}
        - {{ severity }}
    {%- endfor %}
  {%- endif %}
      - install: true
{%- endif %}


{%- set local = windows.system.windows_updates.settings %}
{%- if windows.system.enabled and local.enabled is defined and local.enabled %}
windows.system.windows_updates.settings:
  module.run:
    - win_wua.set_wu_settings:
  {%- if local.level is defined %}
      - level: {{ local.level }}
  {%- endif %}
  {%- if local.recommended is defined %}
      - recommended: {{ local.recommended }}
  {%- endif %}
  {%- if local.featured is defined %}
      - featured: {{ local.featured }}
  {%- endif %}
  {%- if local.elevated is defined %}
      - elevated: {{ local.elevated }}
  {%- endif %}
  {%- if local.msupdate is defined %}
      - msupdate: {{ local.msupdate }}
  {%- endif %}
  {%- if local.day is defined %}
      - day: {{ local.day }}
  {%- endif %}
  {%- if local.time is defined %}
      - time: {{ local.time }}
  {%- endif %}
{%- endif %}
#}