#!/bin/bash

bundle install

# Ensure this build is sane
bundle exec rspec spec

# Ensure there is no existing version
bundle exec gem uninstall pathspec

# Clear old artifacts
rm pathspec-*.gem

# Build and install!
bundle exec gem build pathspec.gemspec && bundle exec gem install pathspec-*.gem
