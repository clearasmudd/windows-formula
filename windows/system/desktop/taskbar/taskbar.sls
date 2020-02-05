# sls: {{ sls }}
# slspath: {{ slspath }}
{% set tstamp = salt["cmd.powershell"]("Get-Date -Format 'MM/dd/yyyy HH:mm:ss K'") %}
{% if salt['grains.get']('taskbarlayout') != 'imported' %}
  {% if 'saltstack' in pillar %}
  {% set taskbar_file_location = '${env:HOMEDRIVE}' + pillar.saltstack.minion.file_roots.base | \
     replace('/','\\') + '\\' + tpldir | replace('/','\\') + '\\taskbarlayout.xml'%}
import_taskbarlayout:
  cmd.run:
    - name: Import-StartLayout -LayoutPath "{{ taskbar_file_location }}" -MountPath "${env:HOMEDRIVE}\"
    - shell: powershell
    - onlyif: if (!(Test-Path {{ taskbar_file_location }} -PathType Leaf)) {exit 1}

set_taskbarlayout_grain:
  grains.present:
    - name: taskbarlayout
    - value: imported
    - require:
      - import_taskbarlayout

# open bug on error https://github.com/saltstack/salt/pull/53464
set_pending_reboot:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired
    - vname: set_from_saltstack
    - vdata: {{ tstamp }}
    - vtype: REG_SZ
    - require:
      - import_taskbarlayout
# failure:
#   test.fail_without_changes:
#     - name: "OS not supported!"
#     - failhard: True
  {% endif %}
{% endif %}