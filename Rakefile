begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'rspec rake task failed to load'
end

require 'rubocop/rake_task'
require 'kramdown'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: %i[rubocop spec man_pages]

desc 'Generate man page for executable script'
task :man_pages do
  kramdown = Kramdown::Document.new(File.read('docs/pathspec-rb.md'))
  File.open('docs/man/pathspec-rb.man.1', 'w') do |f|
    f.write(kramdown.to_man)
  end

  File.open('docs/html/pathspec-rb.html', 'w') do |f|
    f.write(kramdown.to_html)
  end
end
