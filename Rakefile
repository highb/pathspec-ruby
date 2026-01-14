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

desc 'Run tests across all Ruby versions using Docker'
task :test_matrix do
  ruby_versions = ['3.2', '3.3', '3.4', '4.0.1']
  failed_versions = []

  ruby_versions.each do |version|
    puts "\n#{'=' * 80}"
    puts "Testing with Ruby #{version}"
    puts '=' * 80

    cmd = [
      'docker', 'run', '--rm',
      '-v', "#{Dir.pwd}:/app",
      '-w', '/app',
      "ruby:#{version}",
      'bash', '-c',
      'bundle install && bundle exec rake rubocop spec docs'
    ].shelljoin

    success = system(cmd)
    failed_versions << version unless success
  end

  if failed_versions.any?
    puts "\n#{'=' * 80}"
    puts "FAILED on Ruby versions: #{failed_versions.join(', ')}"
    puts '=' * 80
    exit 1
  else
    puts "\n#{'=' * 80}"
    puts 'All Ruby versions passed!'
    puts '=' * 80
  end
end
