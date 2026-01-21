#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark/ips'
require 'pathspec'

# Benchmark configuration
PATTERN_COUNTS = [1, 5, 15, 25, 50, 100, 150].freeze
WARMUP_TIME = 2
BENCHMARK_TIME = 5

# Generate a representative set of file paths for testing
def generate_test_paths(count = 1000)
  paths = []

  # Mix of different path types
  extensions = %w[.rb .txt .log .tmp .swp .md .yml .json .xml .css .js .html]
  directories = %w[src lib test spec config docs bin tmp coverage vendor]

  count.times do |i|
    depth = rand(1..4)
    parts = depth.times.map { directories.sample }
    filename = "file#{i}#{extensions.sample}"
    paths << File.join(*parts, filename)
  end

  paths
end

# Generate gitignore patterns of varying complexity
def generate_patterns(count)
  base_patterns = base_gitignore_patterns

  # Return the first 'count' patterns, cycling if needed
  if count <= base_patterns.length
    base_patterns.take(count)
  else
    patterns = base_patterns.dup
    remaining = count - base_patterns.length
    remaining.times do |i|
      patterns << "generated_pattern_#{i}/**/*"
    end
    patterns
  end
end

# rubocop:disable Metrics/MethodLength
def base_gitignore_patterns
  [
    '*.log',
    '*.tmp',
    '*.swp',
    'coverage/',
    'tmp/',
    'vendor/bundle/',
    '.DS_Store',
    '*.gem',
    'node_modules/',
    'dist/',
    'build/',
    '*.pyc',
    '__pycache__/',
    '.env',
    '.env.local',
    'secrets.yml',
    '*.sqlite3',
    'log/*.log',
    'tmp/**/*',
    'public/assets/',
    '.bundle/',
    'vendor/cache/',
    'doc/',
    '.yardoc/',
    'coverage/**/*',
    '*.rbc',
    '*.sassc',
    '.sass-cache/',
    'Gemfile.lock',
    '.ruby-version',
    '.ruby-gemset',
    '.rvmrc',
    '/config/database.yml',
    '/config/secrets.yml',
    '/config/credentials.yml.enc',
    'npm-debug.log',
    'yarn-error.log',
    '.idea/',
    '*.iml',
    '.vscode/',
    '*.code-workspace',
    '.project',
    '.classpath',
    '.settings/',
    'target/',
    '*.class',
    '*.jar',
    '*.war',
    'bin/',
    'obj/',
    '*.exe',
    '*.dll',
    '*.so',
    '*.dylib',
    '**/*.backup',
    '**/*.bak',
    '**/*.old',
    '**/._*',
    '**/.~lock.*',
    'test/fixtures/files/',
    'spec/fixtures/files/',
    '!important.txt',
    '!config/database.yml.example',
    'cache/**/*.cache',
    '*.min.js',
    '*.min.css',
    'dist/**/*.map',
    'vendor/**/*.js',
    'public/uploads/',
    'storage/',
    '**/*.zip',
    '**/*.tar.gz',
    '**/*.rar',
    '.git/',
    '.gitignore',
    '.gitmodules',
    '.gitattributes',
    'Thumbs.db',
    'Desktop.ini',
    '*.lnk',
    '*.stackdump',
    '*.pid',
    '*.seed',
    '*.log.*',
    'pids/',
    'logs/',
    'results/',
    '.npm/',
    '.eslintcache',
    '.stylelintcache',
    'reports/',
    '*.tsbuildinfo',
    '.tox/',
    '.pytest_cache/',
    '.coverage',
    'htmlcov/',
    '*.prof',
    '*.lprof',
    '*.sage.py',
    'celerybeat-schedule',
    '*.mo',
    '*.pot',
    'local_settings.py',
    'db.sqlite3',
    'db.sqlite3-journal',
    'media/',
    'staticfiles/',
    '.webassets-cache/',
    'instance/',
    '.scrapy/',
    '.ipynb_checkpoints/',
    '__pypackages__/',
    '*.manifest',
    '*.spec',
    'pip-log.txt',
    'pip-delete-this-directory.txt',
    '.env.*.local',
    '.cache/',
    '.parcel-cache/',
    '.next/',
    'out/',
    '.nuxt/',
    '.vuepress/dist/',
    '.serverless/',
    '.fusebox/',
    '.dynamodb/',
    '.tern-port',
    '.vscode-test',
    '.yarn/cache/',
    '.yarn/unplugged/',
    '.yarn/build-state.yml',
    '.yarn/install-state.gz',
    '.pnp.*'
  ]
end
# rubocop:enable Metrics/MethodLength

puts 'PathSpec Performance Benchmark'
puts '=' * 80
puts 'Testing pattern matching performance with varying pattern counts'
puts 'Hardware: Apple M4 Pro (12 cores: 8 performance + 4 efficiency), 24 GB RAM'
puts "Ruby Version: #{RUBY_VERSION}"
puts 'Test Configuration:'
puts "  - Pattern counts: #{PATTERN_COUNTS.join(', ')}"
puts '  - Test paths: 1000 representative file paths'
puts "  - Warmup time: #{WARMUP_TIME}s"
puts "  - Benchmark time: #{BENCHMARK_TIME}s per test"
puts '=' * 80
puts

# Pre-generate test data
test_paths = generate_test_paths(1000)
puts "Generated #{test_paths.length} test paths for benchmarking\n\n"

results = {}

PATTERN_COUNTS.each do |pattern_count|
  patterns = generate_patterns(pattern_count)
  pathspec = PathSpec.new(patterns, :git)

  puts "Benchmarking with #{pattern_count} patterns..."
  puts '-' * 80

  results[pattern_count] = {}

  # Benchmark 1: Single path matching
  Benchmark.ips do |x|
    x.config(time: BENCHMARK_TIME, warmup: WARMUP_TIME)

    x.report('match (single path)') do
      test_paths.first(10).each do |path|
        pathspec.match(path)
      end
    end
  end

  # Store the result (we'll capture this manually from output)
  puts

  # Benchmark 2: Batch path matching
  # Note: match_paths expects paths relative to root, so we pass empty root
  Benchmark.ips do |x|
    x.config(time: BENCHMARK_TIME, warmup: WARMUP_TIME)

    x.report('match_paths (100 paths)') do
      pathspec.match_paths(test_paths.first(100), '')
    end
  end

  puts

  # Benchmark 3: Pattern initialization
  Benchmark.ips do |x|
    x.config(time: BENCHMARK_TIME, warmup: WARMUP_TIME)

    x.report('initialization') do
      PathSpec.new(patterns, :git)
    end
  end

  puts "\n"
end

puts '=' * 80
puts 'Benchmark complete!'
puts '=' * 80
puts "\nTo analyze results:"
puts '1. Review the iterations/second (i/s) for each pattern count'
puts '2. Compare how performance scales as pattern count increases'
puts '3. Identify which operations are most affected by pattern count'
puts "\nNote: Higher i/s (iterations per second) indicates better performance"
