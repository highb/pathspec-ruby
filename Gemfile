source 'https://rubygems.org'

group(:test) do
  gem 'rspec', :require => 'spec'
  gem "fakefs", :require => "fakefs/safe"
  gem 'simplecov'

  if RUBY_VERSION =~ /1.*8.*/
    gem 'ruby-debug'
  else
    gem 'pry', :require => 'pry'
    gem 'pry-debugger'
  end
end
