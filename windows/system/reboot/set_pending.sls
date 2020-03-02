# open bug on error https://github.com/saltstack/salt/pull/53464
set_pending_reboot:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired
    - vname: set_from_saltstack
    - vdata: {{ tstamp }}
    - vtype: REG_SZ
    - require:
      - import_taskbarlayout