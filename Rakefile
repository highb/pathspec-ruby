# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'rspec rake task failed to load'
end

require 'rubocop/rake_task'
require 'kramdown'
require 'fileutils'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: %i[rubocop spec docs]

desc 'Generate man page for executable script'
task :docs do
  kramdown = Kramdown::Document.new(File.read('docs/pathspec-rb.md'))

  File.write('docs/index.html', kramdown.to_html)

  FileUtils.mkdir_p 'docs/man'
  File.write('docs/man/pathspec-rb.man.1', kramdown.to_man)
end
