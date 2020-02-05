# -*- coding: utf-8 -*-
# vim: ft=sls
{%- if grains['kernel'] == 'Windows' %}
  {%- from "windows/map.jinja" import windows with context %}
  {%- if windows is defined %}
include:
  {%- if windows.states is defined %}
  - .states
  {%- endif %}
  {%- if windows.modules is defined %}
  - .modules
  {%- endif %}
    {%- if windows.system is defined %}
  - .system
    {%- endif %}
  {%- endif %}
{%- endif %}