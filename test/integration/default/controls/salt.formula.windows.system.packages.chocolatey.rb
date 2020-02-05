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

require_relative '../libraries/helpers'

pillar = get_pillar

control 'Chocolatey Package Installed' do
  impact 'critical'
  title 'salt.formula.windows.system.packages.chocolatey'
  tag 'timezone', 'saltstack', 'salt.states.chocolatey', 'salt.states.chocolatey.installed',
      'salt.formula.windows.system.packages.chocolatey', 'configuration management'
  ref 'salt.states.chocolatey.installed',
      url: 'https://docs.saltstack.com/en/master/ref/states/all/salt.states.chocolatey.html#salt.states.chocolatey.installed'
  pillar_chocolatey = pillar.dig('windows', 'system', 'packages', 'chocolatey')
  # There is a bug with multiple only_if statements, if any fail it will always report that
  # it `Skipped control due to only_if condition:` for the last only_if statement.
  only_if 'chocolatey is enabled in pillar' do
    !pillar_chocolatey.nil? && pillar_chocolatey['enabled']
  end
  only_if '`installed` key is iterable' do
    pillar_chocolatey.dig('installed').respond_to? :each
  end
  only_if 'chocolatey is installed' do
    command('choco').exist?
  end
  # require 'pry'; binding.pry;
  # require 'pp'; puts "CHOCOLATEY: "; pp pillar_chocolatey;
  pillar_chocolatey.dig('installed').each do |package|
    # pillar_chocolatey['installed'].each do |package|
    # print ": "; pp
    # print "package: "; pp package # ["notepadplusplus", nil], ["windirstat", {"version"=>"1.1.2.20161210"}]
    # print "package[0]: "; pp package[0] # "notepadplusplus", "windirstat"
    # print "package[1]: "; pp package[1] # nil/"None":String, {"version"=>"1.1.2.20161210"}
    # print "package[1].nil?: "; pp package[1].nil?
    # print "package[1].is_a? String: "; pp (package[1].is_a? String)
    # print "package[1].respond_to?(:key?): "; pp (package[1].respond_to?(:key?))
    # print "package[1] == \"None\": "; pp (package[1] == "None")
    # unless package[1].nil? or package[1].kind_of?(String)
    describe chocolatey_package(package[0]) do
      it { should be_installed }
      if (package[1].respond_to? :key?) && package[1].key?('version')
        its ('version') { should cmp package[1]['version'] }
      end
    end
  end
end

####################
# when using pillar from minion
# CHOCOLATEY:
# {"enabled"=>true,
#  "installed"=>
#   {"notepadplusplus"=>"None", "windirstat"=>{"version"=>"1.1.2.20161210"}}}
# package: ["notepadplusplus", "None"]
# package[0]: "notepadplusplus"
# package[1]: "None"
# package[1].nil?: false
# package[1].is_a? String: true
# package[1].respond_to?(:key?): false
# package[1] == "None": true
# package: ["windirstat", {"version"=>"1.1.2.20161210"}]
# package[0]: "windirstat"
# package[1]: {"version"=>"1.1.2.20161210"}
# package[1].nil?: false
# package[1].is_a? String: false
# package[1].respond_to?(:key?): true
# package[1] == "None": false
####################

####################
# when using pillar from test file
# CHOCOLATEY:
# {"enabled"=>true,
#  "installed"=>
#   {"notepadplusplus"=>nil, "windirstat"=>{"version"=>"1.1.2.20161210"}}}
# package: ["notepadplusplus", nil]
# package[0]: "notepadplusplus"
# package[1]: nil
# package[1].nil?: true
# package[1].is_a? String: false
# package[1].respond_to?(:key?): false
# package[1] == "None": false
# package: ["windirstat", {"version"=>"1.1.2.20161210"}]
# package[0]: "windirstat"
# package[1]: {"version"=>"1.1.2.20161210"}
# package[1].nil?: false
# package[1].is_a? String: false
# package[1].respond_to?(:key?): true
# package[1] == "None": false
####################
# require 'safe_yaml'
# pillar = YAML.safe_load(File.read('test/salt/pillar/windows.sls'))

# if pillar['windows']['system']['packages']['chocolatey']['enabled']
#   control 'Chocolatey Packages' do
#     title ''
#     pillar['windows']['system']['packages']['chocolatey']['installed'].each do |package|
#       describe chocolatey_package(package[0]) do
#         it { should be_installed }
#         unless package[1].nil?
#           if package[1].key?('version')
#             its('version') { should cmp package[1]['version'] }
#           end
#         end
#       end
#     end
#   end
# end

####
# 1.Check whether certain application is able to launched (e.g. Acrobat Reader is able to be launched
# without errors)
# - Upon completion of new hardware imaging, check the correct version of Windows 10 OS is installed
# - When new Office version is installed
# - Multiple software can be launch and open concurrently.
# where.exe /f /r "c:\Program Files (x86)" mobaxterm
# get-command git | select source -ExpandProperty source
# https://superuser.com/questions/49104/how-do-i-find-the-location-of-an-executable-in-windows
# script = <<-EOH
#   # Open Internet Explorer
#   $Browser = "C:\\Program Files\\Internet Explorer\\iexplore.exe"
#   Start-Process $Browser
# EOH

# describe powershell(script) do
#   its('stdout') { should eq '' }
#   its('stderr') { should eq '' }
# end
