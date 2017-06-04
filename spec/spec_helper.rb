begin
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
rescue
  puts 'SimpleCov failed to start, most likely this due to running Ruby 1.8.7'
end
