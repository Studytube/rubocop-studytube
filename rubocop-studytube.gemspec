# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'rubocop-studytube'
  s.version     = '0.0.4'
  s.summary     = "Studytube's rubocop rules"
  s.required_ruby_version = '>= 2.7.0'
  s.description = "A set of rubocop rules for studytube's codebase"
  s.authors     = ['Max Nedelchev']
  s.email       = 'max.nedelchev@gmail.com'
  s.files       = ['lib/rubocop-studytube.rb', 'lib/rubocop/cop/studytube/include_service_base.rb']
  s.homepage    =
    'https://github.com/StudyTube/rubocop-studytube'
  s.license = 'MIT'
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rubocop', '~> 1.45.1'
end
