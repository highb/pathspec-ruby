source 'https://rubygems.org'

group(:test) do
  gem 'rspec', :require => 'spec'
  gem "fakefs", :require => "fakefs/safe"
  gem 'codecov', :require => false
end

group(:development) do
  gem 'simplecov', :require => 'simplecov'
  if RUBY_VERSION =~ /1.*8.*/
    gem 'ruby-debug'
  else
    gem 'pry', :require => 'pry'
  end
end
