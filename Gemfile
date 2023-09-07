# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'debug'
gem 'rspec'
gem 'rubocop'
gem 'rubocop-extension-generator'
gem "activesupport", ">= 7.0.7.1"

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
