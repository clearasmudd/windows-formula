# -*- coding: utf-8 -*-
# vim: ft=sls
{%- set masterless_minion = (opts['file_client'] == 'local') %}

{%- if salt['pkg.version']('git') %}
  {%- set git_installed = True %}
{%- else %}
  {%- set git_installed = False %}
{%- endif %}

{%- if masterless_minion %}
  {%- set minion_winrepo_dir_ng = opts['winrepo_dir_ng'] | default('/srv/salt/win/repo-ng', true) %}
  {%- set minion_winrepo = minion_winrepo_dir_ng + "/salt-winrepo-ng" %}
  {%- set minion_cachedir = opts['cachedir'] | default('c:\\salt\\var\\cache\\salt\\minion', true) %}

  {%- if git_installed %}
winrepo.update_git_repos:
  module.run:
    - winrepo.update_git_repos:
    - if_missing: {{ minion_winrepo_dir_ng  }}/salt-winrepo-ng
    - onchanges_in:
      - pkg.refresh_db
  {%- else %}
{# Can't use winrepo.update_git_repos on masterless minion's first state apply because git isn't installed yet. #}
{# Issues: https://github.com/saltstack/salt/issues/47988, https://github.com/saltstack/salt/issues/55013, https://github.com/saltstack/salt/issues/9876 #}
manually.update_git_repo-ng:
  archive.extracted:
    - name: {{ minion_winrepo_dir_ng }}
    - source: https://github.com/saltstack/salt-winrepo-ng/archive/master.zip
    - skip_verify: True
    - if_missing: {{ minion_winrepo }}

rename-extract:
  module.run:
    - file.rename:
      - src: {{ minion_winrepo }}-master
      - dst: {{ minion_winrepo }}
    - onchanges:
      - manually.update_git_repo-ng
    - onchanges_in:
      - pkg.refresh_db
  {%- endif %}

pkg.refresh_db:
  module.run:
    - pkg.refresh_db:
      - failhard: False
    - check_cmd:
      - dir {{ minion_cachedir }}\files\base\win\repo-ng\salt-winrepo-ng
  {%- if not git_installed %}
    {# need on masterless minion's first state apply if manually.update_git_repo-ng is used #}
    - retry:
        attempts: 10
        until: True
        interval: 5
  {%- endif %}
{%- endif %}