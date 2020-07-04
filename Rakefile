begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'rspec rake task failed to load'
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: %i[rubocop spec man_pages]

desc "Generate man page for executable script"
task :man_pages do
  rst2man = %x{which rst2man}.chomp
  unless File.executable?(rst2man)
    abort("rst2man could not be found and is needed to build man pages")
  end

  %x{rst2man docs/man/pathspec-rb.man.1.rst > docs/man/pathspec-rb.man.1}
end
