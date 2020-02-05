# frozen_string_literal: true

# -*- mode: ruby -*-

# vi: ft=ruby
source 'https://rubygems.org'

gem 'kitchen-docker', '>= 2.9'
gem 'kitchen-inspec', '>= 1.1'
gem 'kitchen-salt', '>= 0.6.0'
gem 'kitchen-vagrant', '>= 1.6.0'
gem 'safe_yaml'
# Latest versions of `train` cause failure when running `kitchen verify`
# Downgrading to `3.2.0` until this is fixed upstream
# https://github.com/inspec/train/pull/544#issuecomment-566055052
gem 'train', '3.2.0'
group :hyperv do
  gem 'kitchen-hyperv', '>= 0.5.3'
end
