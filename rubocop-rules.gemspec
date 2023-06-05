Gem::Specification.new do |s|
  s.name        = 'rubocop-rules'
  s.version     = '0.0.1'
  s.summary     = "Studytube's rubocop rules"
  s.required_ruby_version = '>= 2.7.0'
  s.description = "A set of rubocop rules for studytube's codebase"
  s.authors     = ['Max Nedelchev']
  s.email       = 'max.nedelchev@gmail.com'
  s.files       = ['lib/rubocop-rules.rb']
  s.homepage    =
    'https://github.com/StudyTube/rubocop-rules'
  s.license = 'MIT'
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rubocop', '~> 1.45.1'
end
