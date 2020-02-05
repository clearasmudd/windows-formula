# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import windows with context %}
{%- set local = windows.system.reboot %}
{%- if windows.system.enabled and local.enabled %}
windows.system.reboot:
  module.run:
    - system.reboot:
      - only_on_pending_reboot: {{ local.only_on_pending_reboot }}
      - timeout: {{ local.timeout_in_seconds }}
      - in_seconds: True
      - wait_for_reboot: False
    - order: last
{% endif %}