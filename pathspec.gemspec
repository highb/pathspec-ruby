# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'pathspec'
  s.version = '2.1.0'
  s.summary = 'PathSpec: for matching path patterns'
  s.description = 'Use to match path patterns such as gitignore'
  s.authors = ['Brandon High']
  s.email = 'highb@users.noreply.github.com'
  s.files = Dir.glob('{lib,docs}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  s.bindir = 'bin'
  s.executables << 'pathspec-rb'
  s.require_paths = ['lib']
  s.metadata['allowed_push_host'] = 'https://rubygems.org'
  s.metadata['rubygems_mfa_required'] = 'true'
  s.homepage = 'https://github.com/highb/pathspec-ruby'
  s.license = 'Apache-2.0'
  s.required_ruby_version = '>= 3.1.0'
  s.add_development_dependency 'bundler', '~> 2.2'
  s.add_development_dependency 'fakefs', '~> 2.5'
  s.add_development_dependency 'kramdown', '~> 2.3'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rubocop', '~> 1.63.0'
  s.add_development_dependency 'simplecov', '~> 0.21'
end
