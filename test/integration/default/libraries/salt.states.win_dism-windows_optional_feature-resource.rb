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

class WindowsOptionalFeature < Inspec.resource(1)
  name 'windows_optional_feature'
  supports platform: 'windows'
  desc 'Use the windows_feature InSpec audit resource to test optional features on Microsoft Windows Desktops.'
  example <<~EXAMPLE
    # Get-WindowsOptionalFeature Example
    describe windows_optional_feature('TelnetClient') do
      it { should be_installed }
    end
  EXAMPLE

  def initialize(optional_feature)
    @optional_feature = optional_feature
    @cache = nil
    return skip_resource "The `windows_optional_feature` resource is not supported on your OS." unless inspec.os.windows?
    return skip_resource "The `windows_optional_feature` resource is not supported on server OSs, use `windows_feature` instead." if server?
  end

  def installed?
    # State changed to number when converted to json
    # info[:State] == 'Enabled'
    info[:State] == '2'
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