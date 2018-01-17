lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'pathspec'
  s.version = '0.2.1'
  s.date = '2018-01-11'
  s.summary = 'PathSpec: for matching path patterns'
  s.description = 'Use to match path patterns such as gitignore'
  s.authors = ['Brandon High']
  s.email = 'bh@brandon-high.com'
  s.files = Dir.glob('{lib,spec}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  s.bindir = 'bin'
  s.executables << 'pathspec-rb'
  s.test_files = s.files.grep(%r{^spec/})
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/highb/pathspec-ruby'
  s.license = 'Apache-2.0'
  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'fakefs', '~> 0.13'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.52'
  s.add_development_dependency 'simplecov', '~> 0.15'
end
