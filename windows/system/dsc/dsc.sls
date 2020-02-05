# https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget?view=powershell-6

# win_psget is currently broken https://github.com/saltstack/salt/pull/52838, https://github.com/saltstack/salt/pull/54568
# module.run:
# - psget.bootstrap:
# - psget.install:
#   - name: cChoco

{#
{% if salt.pillar.get('windows:powershell:packageproviders:install', None) != None %}
  {% if pillar.windows.powershell.packageproviders.install is iterable %}
    {% for packageprovider, context in salt['pillar.get']('windows:powershell:packageproviders:install', {}).items() %}
"install_powershell_packageprovider_{{ packageprovider }}":
  cmd.run:
    - name: Get-PackageProvider -Name {{ packageprovider }} -ForceBootstrap
    - shell: powershell
    - onlyif: if ((Get-PackageProvider -Name {{ packageprovider }} -ErrorAction SilentlyContinue) -ne $null) {exit 1}
    {% endfor %}
  {% endif %}
{% endif %}

{% if salt.pillar.get('windows:powershell:modules:install', None) != None %}
  {% if pillar.windows.powershell.modules.install is iterable %}
    {% for module, context in salt['pillar.get']('windows:powershell:modules:install', {}).items() %}
"install_powershell_module_{{ module }}":
  cmd.run:
    - name: Install-Module -Name {{ module }} -Force
    - shell: powershell
    - onlyif: if ((Get-InstalledModule | where Name -eq {{ module }}) -ne $null) {exit 1}
    {% endfor %}
  {% endif %}
{% endif %}
#}
{{ pillar.windows.dsc.client.root }}:
  file.directory:
    - makedirs: True

set_lcm_configuration:
  module.run:
    - dsc.set_lcm_config:
      - config_mode: ApplyAndMonitor
      - reboot_if_needed: True
      - action_after_reboot: ContinueConfiguration
      - refresh_mode: Push
    - dsc.get_lcm_config:
    - unless: powershell -command "if ((Get-DscConfigurationstatus -all | where {($_.Status -eq 'Success') \
              -and ($_.Type -eq 'LoocalConfigurationManager')}) -ne $null) {exit 1}"

dsc_copy_configuration:
  file.managed:
    - name: {{ pillar.windows.dsc.client.root }}{{ pillar.windows.dsc.manifest.configuration }}.ps1
    - source: {{ pillar.windows.dsc.manifest.source }}{{ pillar.windows.dsc.manifest.configuration }}.ps1

dsc_compile_configuration:
  module.run:
    - dsc.compile_config:
      - path: {{ pillar.windows.dsc.client.root }}{{ pillar.windows.dsc.manifest.configuration }}.ps1
    - onchanges:
      - dsc_copy_configuration
    - require:
      - set_lcm_configuration

dsc_apply_configuration:
  module.run:
    - dsc.apply_config:
      - path: {{ pillar.windows.dsc.client.root }}{{ pillar.windows.dsc.manifest.configuration }}
    - onlyif: powershell -command "if (((Test-DscConfiguration -ErrorAction SilentlyContinue -Path \
              {{ pillar.windows.dsc.client.root }}{{ pillar.windows.dsc.manifest.configuration }}).InDesiredState)) {exit 1}"
    - require:
      - set_lcm_configuration

# run = compile + apply
# dsc_run_configuration:
#   module.run:
#     - dsc.run_config:
#       - path: {{ pillar.windows.dsc.client.root }}{{ pillar.windows.dsc.manifest.configuration }}.ps1
#     - unless: powershell -command "if ((Test-DscConfiguration -Path {{ pillar.windows.dsc.client.root }}"

dsc_get_configuration:
  module.run:
    - dsc.get_config:
    - retry: # dsc.apply_config doesn't always complete before returning
        attempts: 5
        until: True
        interval: 10
    - onchanges:
      - dsc_apply_configuration