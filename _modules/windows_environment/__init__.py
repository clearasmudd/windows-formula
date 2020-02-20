# -*- coding: utf-8 -*-
# vim: ft=py
# Author: https://github.com/xxsim3lu
# Source: https://github.com/saltstack/salt/issues/9876#issuecomment-488656118
# Issues: https://github.com/saltstack/salt/issues/47988, https://github.com/saltstack/salt/issues/55013,https://github.com/saltstack/salt/issues/9876

from __future__ import absolute_import
import logging
import salt.utils.platform
import re

log = logging.getLogger(__name__)

__virtualname__ = 'windows_environment'


def __virtual__():
    if salt.utils.platform.is_windows():
        return __virtualname__

    return False, 'ssh_known_hosts: Does not support Linux'


def refresh(environment_variable='PATH'):
    ret = {}
    # ====== Get the environment from registry ======
    cmd = 'reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
    res = __salt__['cmd.run'](cmd=cmd)
    tmp = res.splitlines()
    environ = {}
    for item in tmp:
        val = item.strip().split('    ')
        if len(val) == 3:
            environ.update({val[0].strip().upper(): val[2].strip()})

    # ====== Resolve the environment values and replace them ======
    # ====== e.g. %systemroot% to 'C:\Windows' ======
    for key, value in environ.items():
        matches = re.findall(r'%(.+?)%', value)
        match = set([i.upper() for i in matches])
        for item in match:
            a = environ.get(item)
            if not a:
                a = __salt__['environ.get'](item)

            if a:
                redata = re.compile(
                    re.escape('%{}%'.format(item)), re.IGNORECASE)
                environ[key] = redata.sub(a, value)

    # ====== Only set the PATH environment ======
    setenviron = {'PATH': environ.get(environment_variable)}
    ret = __salt__['environ.setenv'](environ=setenviron, update_minion=True)
    return ret
