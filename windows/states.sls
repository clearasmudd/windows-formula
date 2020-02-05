# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/macros.jinja" import states with context %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.states %}
{%- if local.enabled %}
  {{ states(local) }}
{%- endif %}

{#
    https://stackoverflow.com/questions/36886650/how-to-add-a-new-entry-into-a-dictionary-object-while-using-jinja2
    Python2? {% set x=my_dict.__setitem__("key", "value") %}
    {%- set update={'utc':false} %}
    {%- set _ = local.timezone.system.update({'utc':false} ) -%}
    {{ states(local, 'system') }}
{{ states(local, 'timezone.system') }}
{{ modules(windows.modules, 'user.current') }}
{{ modules(windows.modules, 'status') }}
{{ states(windows.states, 'timezone') }}
#}
