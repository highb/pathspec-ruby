begin
    require 'rspec/core/rake_task'
      RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
end
