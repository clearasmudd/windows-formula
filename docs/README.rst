.. _readme:

####################
windows-formula
####################

| |img_semver| |img_releasedate| |img_sr| |img_license|
|
| |img_appveyor_master| |img_appveyor_tests| |img_readthedocs|
|
| |img_codacy| |img_snyk| |img_librariesio|

.. https://www.appveyor.com/docs/status-badges/#display-badge-for-specific-branch

.. |img_semver| image::  https://img.shields.io/github/v/release/clearasmudd/windows-formula?cacheSeconds=120
   :alt: GitHub release (latest SemVer)
   :scale: 100%
   :target: https://github.com/clearasmudd/windows-formula/releases
.. |img_releasedate| image:: https://img.shields.io/github/release-date/clearasmudd/windows-formula?color=blue&cacheSeconds=120
   :alt: GitHub release date
   :scale: 100%
   :target: https://github.com/clearasmudd/windows-formula/releases
.. |img_sr| image:: http://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg?color=blue&cacheSeconds=120
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_license| image:: https://img.shields.io/github/license/clearasmudd/windows-formula?color=blue&cacheSeconds=120
   :alt: License
   :scale: 100%
   :target: https://github.com/clearasmudd/windows-formula/LICENSE
.. |img_appveyor_master| image:: https://ci.appveyor.com/api/projects/status/5nm6yfh5n5qk1isn/branch/master?svg=true
   :alt: Appveyor Build Master
   :scale: 100%
   :target: https://ci.appveyor.com/project/muddman/windows-formula/branch/master
.. |img_appveyor_tests| image:: https://img.shields.io/appveyor/tests/muddman/windows-formula/master?cacheSeconds=120
   :alt: Appveyor Test Results
   :scale: 100%
   :target: https://ci.appveyor.com/project/muddman/windows-formula/branch/master
.. |img_readthedocs| image:: https://readthedocs.com/projects/clearasmudd-windows-formula/badge/?version=master
   :alt: Read the Docs
   :scale: 100%
   :target: https://clearasmudd-windows-formula.readthedocs-hosted.com/en/latest/?badge=latest
.. |img_librariesio| image:: https://img.shields.io/librariesio/github/clearasmudd/windows-formula?cacheSeconds=120
   :alt: Libraries IO Dependencies
   :scale: 100%
   :target: https://libraries.io/github/clearasmudd/windows-formula
.. |img_codacy| image:: https://api.codacy.com/project/badge/Grade/dbf7bbe2183b4dfe8e1e8736ee48718c
   :alt: Codacy
   :scale: 100%
   :target: https://www.codacy.com/gh/clearasmudd/windows-formula?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=clearasmudd/windows-formula&amp;utm_campaign=Badge_Grade
.. |img_snyk| image:: https://snyk.io/test/github/clearasmudd/windows-formula/badge.svg
   :alt: snyk
   :scale: 100%
   :target: https://snyk.io/test/github/clearasmudd/windows-formula

A SaltStack formula for Windows operating systems inspired by `salt-formula-linux <https://github.com/salt-formulas/salt-formula-linux>`_. 

Tested Windows Operating Systems:

* Windows 10, version 1909
* Windows 10, version 1903
* Windows 10, version 1809
* Windows 10, version 1803
* Windows 10, version 1709
* Windows Server 2019, version 1809
* Windows Server 2016, version 1607
* Windows Server 2012 R2

.. contents:: **Table of Contents**
    :depth: 3

General notes
=======================

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please pay attention to the ``pillar.example`` file and/or `Special notes`_ section.

Available states
=======================

.. contents::
   :local:
   :depth: 1

``windows``
--------------------------

"Meta-state (This is a state that includes other states).

This installs the windows package,
manages the windows configuration file and then
starts the associated windows service.ku
 

``windows.states``
--------------------------

This state uses a jinja macro to render salt `state modules <https://docs.saltstack.com/en/2019.2/ref/states/all/index.html>`_ dynamically 
from the ``windows.states`` pillar dictionary.

Optional
^^^^^^^^^^

These optional dictionary keys can be included with each state definition defined in the pillar.

:enabled (bool): Enabled or disable rendering of a state included in the pillar dictionary.  If the key is not present, it is assumed to be true.

:id (str): If provided, ``id`` will be used as the `ID Declaration <https://docs.saltstack.com/en/2019.2/ref/states/highstate.html#id-declaration>`_ suffix, instead of ``name`` in the format windows.state.*state_name*.*state_function_name*.*id*.

:global arguments: The use of `requisites and other global state arguments <https://docs.saltstack.com/en/2019.2/ref/states/requisites.html>`_ is supported but has not been exhaustively tested.


Example 1:
^^^^^^^^^^^
The following pillar definition implements the `salt.states.timezone.system <https://docs.saltstack.com/en/2019.2/ref/states/all/salt.states.timezone.html>`_ state module:

.. code-block:: yaml

    windows:
      states:
        enabled: true
        timezone:
          system:
            name: America/New_York
            utc: false

It is rendered as:

.. code-block:: yaml

    windows.state.timezone.system.America/New_York:
      timezone.system:
        - name: America/New_York
        - utc: False

Example 2:
^^^^^^^^^^^
The following pillar definition implements the `salt.states.win_system.computer_desc <https://docs.saltstack.com/en/2019.2/ref/states/all/salt.states.win_system.html#salt.states.win_system.computer_desc>`_, `salt.states.win_system.hostname <https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_system.html#salt.states.win_system.hostname>`_, `salt.states.win_system.reboot <https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_system.html#salt.states.win_system.reboot>`_, salt.states.timezone.system, and `salt.states.win_wua.uptodate <https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_wua.html#salt.states.win_wua.uptodate>`_ state modules, uses the optional ``enabled`` and ``id`` keys and includes the use of the `require <https://docs.saltstack.com/en/latest/ref/states/requisites.html#require>`_ requisite.

.. code-block:: yaml

    windows:
      states:
        enabled: true
        system:
          computer_desc:
            enabled: true
            id: description
            name: "Saltstack Computer Description"
            require:
              - windows.state.system.hostname.saltstack1
          hostname:
            name: "saltstack1"
          reboot:
            enabled: false
            message: rebooting in 60 seconds
            timeout: 60
            in_seconds: true
        timezone:
          system:
            name: America/New_York
            utc: false
        wua:
          uptodate:
            enabled: true
            software: true
            drivers: true
            skip_hidden: false
            skip_mandatory: false
            skip_reboot: false
            categories:
              - Critical Updates
              - Definition Updates
              - Drivers
              - Feature Packs
              - Security Updates
              - Update Rollups
              - Updates
              - Update Rollups
              - Windows Defender
            severities:
              - Critical
              - Important

The ``system.reboot`` state is not rendered as this example has an ``enabled`` key set to ``false``.

.. code-block:: yaml

    windows.state.system.computer_desc.description:
      system.computer_desc:
        - name: Saltstack Computer Description
        - require:
            - windows.state.system.hostname.saltstack1

    windows.state.system.hostname.saltstack1:
      system.hostname:
        - name: saltstack1

    windows.state.timezone.system.America/New_York:
      timezone.system:
        - name: America/New_York
        - utc: False

    windows.state.wua.uptodate:
      wua.uptodate:
        - software: True
        - drivers: True
        - skip_hidden: False
        - skip_mandatory: False
        - skip_reboot: False
        - categories:
            - Critical Updates
            - Definition Updates
            - Drivers
            - Feature Packs
            - Security Updates
            - Update Rollups
            - Updates
            - Update Rollups
            - Windows Defender
        - severities:
            - Critical
            - Important

This approach is `modular and creates a direct relationship between pillars and states <https://docs.saltstack.com/en/2019.2/topics/best_practices.html>`_ , however, there are several tradeoffs.

#. The pure jinja implementation does not go `Easy on the Jinja <https://docs.saltstack.com/en/2019.2/topics/development/conventions/formulas.html#easy-on-the-jinja>`_ so 
changes to the macro can be difficult to debug. 
#. Theoritaclly, this could be used to implement 
any state, which makes exhaustive testing difficult.  Report any issues that are found.

A maximum dept of four is currently supported.

While this state is not windows specific, it has only been tested within the scope of this formula.

``windows.modules``
--------------------------

This state uses a jinja macro to render salt `execution modules <https://docs.saltstack.com/en/2019.2/ref/modules/all/index.html>`_ from pillar dictionaries.

While this state is not windows specific, it has only been tested within the scope of this formula.


Testing
=======================

Linux testing is done with ``kitchen-salt``.

Requirements
--------------------------

* Ruby
* Docker
* Vagrant 2.2.7
* Virtualbox 6.1

.. code-block:: bash

   $ gem install bundler
   $ bundle install
   $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
--------------------------

Creates the docker instance and runs the ``windows`` main state, ready for testing.

``bin/kitchen verify``
--------------------------

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
--------------------------

Removes the docker instance.

``bin/kitchen test``
--------------------------

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
--------------------------

Gives you SSH access to the instance for manual testing.

Manually Run salt on windows:
-------------------------------

``C:\Windows\system32\cmd.exe /c ""C:\salt\salt-call.bat" --state-output=changes --config-dir=C:\Users\vagrant\AppData\Local\Temp\kitchen\etc\salt state.highstate --log-level=trace --retcode-passthrough"``

SaltStack installation
=======================

``Masterless Minion``
--------------------------

https://docs.saltstack.com/en/develop/topics/installation/windows.html

https://raw.githubusercontent.com/saltstack/salt-bootstrap/v2019.10.03/bootstrap-salt.ps1
https://github.com/saltstack/salt-bootstrap/blob/v2019.10.03/bootstrap-salt.ps1

.. Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/saltstack/salt-bootstrap/v2019.10.03/bootstrap-salt.ps1'));bootstrap-salt.ps1 -version 2019.2.2 -runservice false -pythonVersion 3

.. @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/saltstack/salt-bootstrap/v2019.10.03/bootstrap-salt.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"


Contributing to this repo
===========================

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

**Commit message formatting is significant!!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

Commit Message Format
----------------------
Each commit message consists of a **header**, a **body** and a **footer**.  The header has a special
format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

Any line of the commit message cannot be longer 100 characters! This allows the message to be easier
to read on GitHub as well as in various git tools.

Revert
^^^^^^^^^^^^^^^^^^^^^^
If the commit reverts a previous commit, it should begin with `revert: `, followed by the header
of the reverted commit.
In the body it should say: `This reverts commit <hash>.`, where the hash is the SHA of the commit
being reverted.

Type
^^^^^^^^^^^^^^^^^^^^^^
Must be one of the following:

* **feat**: A new feature
* **fix**: A bug fix
* **docs**: Documentation only changes
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing
  semi-colons, etc)
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **perf**: A code change that improves performance
* **test**: Adding missing or correcting existing tests
* **chore**: Changes to the build process or auxiliary tools and libraries such as documentation
  generation

Scope
^^^^^^^^^^^^^^^^^^^^^^
The scope could be anything specifying place of the commit change. For example `$location`,
`$browser`, `$compile`, `$rootScope`, `ngHref`, `ngClick`, `ngView`, etc...

You can use `*` when the change affects more than a single scope.

Subject
^^^^^^^^^^^^^^^^^^^^^^
The subject contains succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize first letter
* no dot (.) at the end

Body
^^^^^^^^^^^^^^^^^^^^^^
Just as in the **subject**, use the imperative, present tense: "change" not "changed" nor "changes".
The body should include the motivation for the change and contrast this with previous behavior.

Footer
^^^^^^^^^^^^^^^^^^^^^^
The footer should contain any information about **Breaking Changes** and is also the place to
[reference GitHub issues that this commit closes][closing-issues].

**Breaking Changes** should start with the word `BREAKING CHANGE:` with a space or two newlines.
The rest of the commit message is then used for this.

A detailed explanation can be found in this `document <https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#>`_.

Special notes
=======================

None

Examples
=======================

.. code-block:: yaml

    windows.state.system.computer_desc.description:
      system.computer_desc:
        - name: Saltstack Computer Description
        - require:
          - windows.state.system.hostname.saltstack1
    windows.state.system.hostname.saltstack1:
      system.hostname:
        - name: saltstack1
    windows.state.timezone.system.America/New_York:
      timezone.system:
        - name: America/New_York
        - utc: False

    windows.module.system.reboot:
      module.run:
        - system.reboot:
          - timeout: 5
          - in_seconds: True
          - only_on_pending_reboot: True
          - wait_for_reboot: False
        - order: last
    windows.module.user.current:
      module.run:
        - user.current:
          - sam: True
    windows.module.status.uptime:
      module.run:
        - status.uptime:
          - human_readable: True
        - require:
          - windows.module.user.current

ToDo
=======================

#. discuss with windows working group: https://github.com/saltstack/community/tree/master/working_groups/wg-Windows

#. Salt builds: https://jenkinsci.saltstack.com/, noxfile.py, https://nox.thea.codes/en/stable/
