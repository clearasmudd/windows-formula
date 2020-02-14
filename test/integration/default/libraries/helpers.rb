# frozen_string_literal: true

# Copyright 2020 Peter Mudd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Peter Mudd (https://github.com/muddman)

# C:\salt\salt-call.bat --config-dir=C:\Users\vagrant\AppData\Local\Temp\kitchen\etc\salt state.show_highstate
# --out yaml |Select-String -Pattern "__sls__", "__env__", "- run", "- order:" -NotMatch

# GENERAL HELPERS
require 'inspec/resources/registry_key'

def server?
  if defined?(@cache_server)
    Inspec::Log.debug('(server?) using cache @cache_server')
    return @cache_server
  end
  begin
    @cache_server = inspec.registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'].match? 'Server'
  rescue StandardError => e
    Inspec::Log.error('(server?) rescue:' + e.message)
    return false
  end
  Inspec::Log.debug('(server?) ending')
  @cache_server
end

# SALTSTACK HELPERS
require 'safe_yaml'
require 'train'
require 'timeout'
require "inspec/log"
require 'json'

# https://www.inspec.io/docs/reference/inputs/
def set_input_pillar_default
  input('pillar', value: get_pillar_default, type: 'hash', description: 'SaltStack Pillar Data')
end

def get_pillar
  if defined?(@cache_pillar)
    Inspec::Log.debug('(get_pillar?) returning cached value')
    return @cache_pillar
  end
  @cache_pillar = try_get_pillar

  if defined?(@cache_pillar)
    Inspec::Log.debug('(get_pillar) success, got pillar.  Cached result.')
    @cache_pillar
  end
end

def try_get_pillar
  # require 'pp'; pp input('pillar').diagnostic_string;
  # REMOVE THIS
  # return get_pillar_from_inspec_pillar_file
  unless input('pillar').is_a?(Inspec::Input::NO_VALUE_SET)
    # Inspec::Log.info('Got pillar from kitchen input.')
    puts 'INFO: Got pillar from kitchen input.'
    return input('pillar')
  end

  # pillar_from_minion = get_pillar_from_minion
  pillar_from_minion = ingest_from_minion('yaml', 'c:\salt\salt-call.bat --config-dir=C:\Users\vagrant\AppData\Local\Temp\kitchen\etc\salt pillar.items --retcode-passthrough | Select-String -Pattern "----------" -NotMatch')
  unless !defined?(pillar_from_minion) || pillar_from_minion == []
    # Inspec::Log.info('Got pillar from the target minion using WinRM.')
    puts 'INFO: Got pillar from the target minion using WinRM.'
    return pillar_from_minion['local']
  end

  pillar_from_inspec_pillar_file = get_pillar_from_inspec_pillar_file
  unless !defined?(pillar_from_inspec_pillar_file) || pillar_from_inspec_pillar_file == []
    # Inspec::Log.info('Got pillar from the inspec pillar file.')
    puts 'INFO: Got pillar from the inspec pillar file.'
    return pillar_from_inspec_pillar_file
  end
  raise 'Unable to get pillar from input, minion or local inspec pillar file.'
end

def get_pillar_from_inspec_pillar_file
  if defined?(@cache_pillar_from_inspec_pillar_file)
    Inspec::Log.debug('[get_pillar_from_inspec_pillar_file] returning cached value')
    return @cache_pillar_from_inspec_pillar_file
  end
  pillar_file = ENV['INSPEC_TEST_SALT_PILLAR'] || 'test/salt/pillar/windows.sls'
  begin
    @cache_pillar_from_inspec_pillar_file = YAML.safe_load(File.read(pillar_file)) if File.exist?(pillar_file)
  rescue StandardError => e
    Inspec::Log.warn('[get_pillar_from_inspec_pillar_file] ' + e.message)
    return []
  end
  if defined?(@cache_pillar_from_inspec_pillar_file)
    Inspec::Log.debug('[get_pillar_from_inspec_pillar_file] success, got the pillar from the inspec file.  Cached result.')
    @cache_pillar_from_inspec_pillar_file
  end
end

def ingest_from_minion(type, ps_cmd, max_retries = 20, sec_timeout = 10)
  retries ||= 0
  Inspec::Log.debug("Ingesting #{type} content using `#{ps_cmd}` with timout of #{sec_timeout} and a max of #{max_retries} retries.")
  begin
    # https://www.rubydoc.info/gems/train/0.14.1/Train%2FTransports%2FLocal%2FConnection:run_command
    # Train.Plugins.Transport.Connection train.connection.run_command
    Timeout.timeout(sec_timeout) do
      @my_result = JSON.parse(backend::backend.run_command(ps_cmd).stdout) if type == 'json'
      @my_result =YAML.safe_load(backend::backend.run_command(ps_cmd).stdout) if type == 'yaml'
    end
  rescue => e
    Inspec::Log.warn("`#{e.message}`, target may be rebooting after highstate. Remaining retries: #{max_retries - retries}")
    retry if (retries += 1) < max_retries
  end
  if defined?(@my_result)
    Inspec::Log.debug("Ingested #{type} content successfully.")
    @my_result
  else
    Inspec::Log.warn('Failed to get content from minion.')
    []
  end
end

# pp get_mystates_from_highstate('module','chocolatey','bootstrap')
# pp get_mystates_from_highstate('module','user','current')
# pp get_mystates_from_highstate('state','system','hostname')
def get_highstate_from_minion
  if defined?(@cache_highstate_from_minion)
    Inspec::Log.debug('Returning cached @cache_highstate_from_minion.')
    return @cache_highstate_from_minion
  end
  # ingest_from_minion('yaml', 'C:\salt\salt-call.bat --config-dir=C:\Users\vagrant\AppData\Local\Temp\kitchen\etc\salt state.show_highstate --out yaml  |Select-String -Pattern "__sls__", "__env__", "- run", "- order:" -NotMatch')
  highstate_from_minion = ingest_from_minion('json', 'C:\salt\salt-call.bat --config-dir=C:\Users\vagrant\AppData\Local\Temp\kitchen\etc\salt state.show_highstate --out json')

  if highstate_from_minion != []
    Inspec::Log.debug('Saving highstate to cache @cache_highstate_from_minion.')
    @cache_highstate_from_minion = highstate_from_minion['local']
    @cache_highstate_from_minion
  else
    Inspec::Log.error('Failed to get highstate.')
    abort 'Failed to get highstate.'
  end
end

# Example modules
# "windows.module.status.uptime"=>
#   {"module"=>
#     [{"status.uptime"=>[{"human_readable"=>true}]},
#      {"require"=>["windows.module.user.current"]},
#      "run",
#      {"order"=>10004}],
#    "__sls__"=>"windows.modules",
#    "__env__"=>"base"},
# "chocolatey.bootstrap"=>
#   {"module"=>
#     [{"chocolatey.bootstrap"=>nil},
#      {"unless"=>"where.exe chocolatey"},
#      "run",
#      {"order"=>10010}],
#    "__sls__"=>"windows.system.packages.chocolatey.bootstrap",
#    "__env__"=>"base"},

# Example State
#    {"windows.state.system.computer_desc.description"=>
#     {"system"=>
#       [{"name"=>"Saltstack Computer Description"},
#        {"require"=>["windows.state.system.hostname.saltstack1"]},
#        "computer_desc",
#        {"order"=>10000}],
#      "__sls__"=>"windows.states",
#      "__env__"=>"base"},

def get_mystates_from_highstate(type, find_state, find_function)
  found_states = {}
  highstate = get_highstate_from_minion
  Inspec::Log.debug("Getting #{type}s for #{find_state}.#{find_function}.")
  # puts "highstate class: " + highstate.class.to_s
  # pp highstate
  highstate.each do |state_id, state|
    # puts "state class: " + state.class.to_s
    Inspec::Log.debug("Checking #{state_id} from highstate.")
    case type
    when 'state'
      if state.key?(find_state) && state[find_state].include?(find_function)
        Inspec::Log.debug("Found state #{find_state}.#{find_function} from highstate.")
        found_states[state_id] = state
      end
    when 'module'
      if state.key?('module')
        check_module = state['module'][0]
        # pp check_module
        if check_module.key?("#{find_state}.#{find_function}") || (check_module.key?(find_state) && check_module[find_state][0] == find_function)
          Inspec::Log.debug("Found module #{find_state}.#{find_function} from highstate.")
          found_states[state_id] = state
        end
      end
    end
  end
  if found_states != {}
    Inspec::Log.debug("Got #{type}s for #{find_state}.#{find_function}.")
    # pp found_states
    found_states
  else
    Inspec::Log.error("Unable to get #{type}'s for #{find_state}.#{find_function}'")
  end
end

# example: get_saltstack_package_full_name('7zip') = '7-Zip'
def get_saltstack_package_full_name(package)
  # pillar = YAML.safe_load(File.read('test/salt/pillar/windows.sls'))
  url = 'https://raw.githubusercontent.com/saltstack/salt-winrepo-ng/master/'
  files = [package + '.sls', package + '/init.sls']
  # example: package = "7zip"=>{"version"=>"18.06.00.0", "refresh_minion_env_path"=>false}
  saltstack_package_full_name = files.find do |checkme|
    ps = "$f = (((Get-ChildItem -Path $env:LOCALAPPDATA -Filter 'salt-winrepo-ng' -Recurse -Directory).Fullname[0])  + '\\#{checkme.sub('/', '\\')}'); if (Test-Path $f -PathType Leaf) {Get-Content -Path $f}"
    begin
      file = (open(url + checkme) & :read)
    rescue
      begin
        file = (powershell(ps).stdout)
      rescue
        next
      end
    end
    unless file.nil? || file.empty?
      candidate = file.match(/full_name: '([\S]+).*'/).captures[0]
    end
    break candidate unless candidate.nil?
  end
  Inspec::Log.debug('[get_saltstack_package_full_name] found candidate: ' + saltstack_package_full_name)
  saltstack_package_full_name
end
