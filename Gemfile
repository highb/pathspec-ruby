source 'https://rubygems.org'

group(:test) do
  gem 'simplecov', :require => false
  gem 'rspec', :require => 'spec'
  gem "fakefs", :require => "fakefs/safe"
  unless RUBY_VERSION =~ /1\.8.*/
    gem 'pry'
    gem 'pry-debugger'
  end
end
