#!/bin/bash
function testversion {
  echo Testing Ruby $1
  rbenv install -s $1
  rbenv local $1
  gem install bundler --quiet
  bundle install --quiet
  bundle exec rspec
  if [ $? -eq 0 ]; then
    echo -e "\033[32mSuccess testing Ruby $1\033[0m"
  else
    echo -e "\033[31mFailed testing Ruby $1 Exit code was $?\033[0m"
  fi
  echo

}

for VERSION in 1.8.7 1.9.3 2.0.0 2.1.1; do
  testversion $VERSION
done
