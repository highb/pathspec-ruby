# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/unit/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:spec_integration) do |t|
    t.pattern = 'spec/integration/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:spec_all) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError
  puts 'rspec rake task failed to load'
end

require 'rubocop/rake_task'
require 'kramdown'
require 'fileutils'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: %i[rubocop spec spec_integration docs]

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
      'bundle install && bundle exec rake rubocop spec spec_integration docs'
    ].shelljoin

    success = system(cmd)
    failed_versions << version unless success
  end

  puts "\n#{'=' * 80}"
  if failed_versions.any?
    puts "FAILED on Ruby versions: #{failed_versions.join(', ')}"
    puts '=' * 80
    exit 1
  else
    puts 'All Ruby versions passed!'
    puts '=' * 80
  end
end

desc 'Run performance benchmarks (requires benchmark-ips gem)'
task :benchmark do
  puts 'Running performance benchmarks...'
  puts 'This may take several minutes to complete.'
  puts

  benchmark_script = File.join(__dir__, 'benchmarks', 'pattern_scaling.rb')

  unless File.exist?(benchmark_script)
    puts 'Error: Benchmark script not found at benchmarks/pattern_scaling.rb'
    exit 1
  end

  # Check if benchmark-ips is available
  begin
    require 'benchmark/ips'
  rescue LoadError
    puts 'Error: benchmark-ips gem is not installed'
    puts 'Please run: bundle install'
    exit 1
  end

  # Run the benchmark script
  system('ruby', benchmark_script) || exit(1)
end
