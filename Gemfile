source 'https://rubygems.org'

group(:test) do
  gem 'rspec', :require => 'spec'
  gem "fakefs", :require => "fakefs/safe"

    gem 'simplecov'
  unless RUBY_VERSION =~ /1\.8.*/
    gem 'pry', :require => 'pry'
    gem 'pry-debugger'
  end
end
