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
# Reference: https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_dism.html

require 'helpers'
require 'safe_yaml'
require 'open-uri'

class SaltstackPackage < Inspec.resource(1)
  name 'saltstack_package'
  supports platform: 'windows'
  desc 'Use the saltstack_package InSpec audit resource to test if a Saltstack package is installed on Microsoft Windows.'
  example <<~EXAMPLE
    describe saltstack_package('7zip') do
      it { should be_installed }
    end
  EXAMPLE

  def initialize(package)
    @package = package
    @package_fullname = convert_package_name
    @cache = nil
    return skip_resource "The `saltstack_package` resource is not supported on your OS." unless inspec.os.windows?
  end

  def installed?
    # State changed to number when converted to json
    # info[:State] == 'Enabled'
    info[:State] == '2'

    if pillar['windows']['system']['packages']['saltstack']['enabled']
      control 'Saltstack Packages' do
        title ''
        pillar['windows']['system']['packages']['saltstack']['installed'].each do |package|
          # example: full_names['7zip] = "7-Zip"
          describe package(@package_fullname).installed? do
            it { should be_installed }
            unless package[1].nil?
              if package[1].key?('version')
                its('version') { should cmp package[1]['version'] }
              end
            end
          end
        end
      end
    end
  end

  def info
    return @cache unless @cache.nil?
    @cache = info_via_powershell(@optional_feature)
      if @cache[:error]
        # TODO: Allow handling `Inspec::Exception` outside of initialize
        # See: https://github.com/inspec/inspec/issues/3237
        # The below will fail the resource regardless of what is raised
        raise Inspec::Exceptions::ResourceFailed, @cache[:error]
      end
    @cache
  end

  def to_s
    "Windows Optional Feature: `#{@optional_feature}`"
    # "`#{@optional_feature}`"
  end

  private

  def convert_package_name
    full_names = {}
    pillar = YAML.safe_load(File.read('test/salt/pillar/windows.sls'))
    url = 'https://raw.githubusercontent.com/saltstack/salt-winrepo-ng/master/'
    files = [@package+ ".sls", @package + "/init.sls"]
    # example: package = "7zip"=>{"version"=>"18.06.00.0", "refresh_minion_env_path"=>false}

    full_names[package[0]] = files.find do |checkme|
      ps = "$f = (((Get-ChildItem -Path $env:LOCALAPPDATA -Filter 'salt-winrepo-ng' -Recurse -Directory).Fullname[0]) + '\\#{checkme.sub('/', '\\')}'); if (Test-Path $f -PathType Leaf) {Get-Content -Path $f}"
      begin
        file = (open(url + checkme) {|f| f.read })
      rescue
        begin
          file = (powershell(ps).stdout)
        rescue
          next
        end
      end
      unless file.nil? or file.empty?
        candidate = file.match(/full_name: '([\S]+).*'/).captures[0]
      end
      break candidate unless candidate.nil?
    end
  end

  def info_via_powershell(optional_feature)
    # ps_cmd = "Get-WindowsOptionalFeature -online | Where-Object {($_.FeatureName -eq '#{optional_feature[0]}') -and ($_.State -eq 'Enabled')} | Select FeatureName -ExpandProperty FeatureName"
    optional_features_cmd = "Get-WindowsOptionalFeature -online | Where-Object {($_.FeatureName -eq '#{optional_feature}')} | Select-Object -Property FeatureName,State | ConvertTo-Json"
    # features_cmd = "Get-WindowsFeature | Where-Object {$_.Name -eq '#{feature}' -or $_.DisplayName -eq '#{feature}'} | Select-Object -Property Name,DisplayName,Description,Installed,InstallState | ConvertTo-Json"
    cmd = inspec.command(optional_features_cmd)
    optional_feature_info = {}
    if cmd.stderr =~ /The term 'Get-WindowsOptionalFeature' is not recognized/
      optional_feature_info[:FeatureName] = optional_feature
      optional_feature_info[:error] = "Could not find `Get-WindowsOptionalFeature `"
    else
      # We cannot rely on `cmd.exit_status != 0` because by default the
      # command will exit 1 even on success. So, if we cannot parse the JSON
      # we know that the feature is not installed.
      begin
        result = JSON.parse(cmd.stdout)
        optional_feature_info = {
          FeatureName: result["FeatureName"],
          State: result["State"].to_s,
        }
      rescue JSON::ParserError => _e
        optional_feature_info[:FeatureName] = optional_feature
        optional_feature_info[:State] = 'Disabled'
      end
    end
    return optional_feature_info
  end
end