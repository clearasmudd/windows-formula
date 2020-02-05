# -*- coding: utf-8 -*-
# vim: ft=sls
{#
    https://docs.saltstack.com/en/master/ref/states/all/salt.states.timezone.html
    https://docs.saltstack.com/en/master/ref/modules/all/salt.modules.timezone.html
    https://docs.saltstack.com/en/master/ref/modules/all/salt.modules.win_timezone.html
#}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.timezone %}
{%- if windows.system.enabled and local is defined %}
windows.system.timezone:
  timezone.system:
    - name: {{ windows.system.timezone }}
    - utc: False
{%- endif %}