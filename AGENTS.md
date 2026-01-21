# AGENTS.md

PathSpec Ruby - .gitignore-style pattern matching in Ruby

## Project overview

Ruby gem implementing .gitignore-style pattern matching with both library API and CLI tool. Supports Ruby 3.2-4.0.1 with comprehensive test coverage and multi-Ruby CI.

## Setup commands

```bash
# Install mise (Ruby version manager)
brew install mise  # macOS
# Other platforms: https://mise.jdx.dev/getting-started.html

# Activate mise
eval "$(mise activate zsh)"  # or bash, fish, etc.

# Install Ruby and bundler versions
mise install

# Install dependencies
mise run install
# or: bundle install
```

## Testing

```bash
# Run all tests (lint, unit, integration, docs)
mise run test
# or: bundle exec rake

# Unit tests only
mise run test:unit
# or: bundle exec rake spec

# Integration tests (CLI) only
mise run test:integration
# or: bundle exec rake spec_integration

# All specs (unit + integration)
mise run test:all
# or: bundle exec rake spec_all

# Cross-Ruby matrix testing via Docker
mise run test:matrix
# or: bundle exec rake test_matrix
```

## Code style

- Use RuboCop 1.63.5 for linting
- Method length limit: 69 lines
- Use single quotes for strings without interpolation
- Use `%w[]` for word arrays
- Auto-fix with: `bundle exec rubocop --autocorrect`
- For large data arrays: add `# rubocop:disable Metrics/MethodLength`

## Build and release

```bash
# Build gem
mise run build
# or: gem build pathspec.gemspec

# Generate documentation
bundle exec rake docs

# Development install
rake install
```

## Project structure

```
pathspec-ruby/
├── lib/pathspec/           # Core library
│   ├── pathspec.rb       # Main PathSpec class
│   └── patterns/         # Pattern implementations
├── bin/pathspec-rb       # CLI executable
├── spec/
│   ├── unit/             # Library tests
│   └── integration/      # CLI tests
├── benchmarks/           # Performance tests
├── docs/                # Documentation source
├── Rakefile            # Build tasks
├── .tool-versions       # Ruby/bundler versions
└── pathspec.gemspec     # Gem spec
```

## Development workflow

1. Make changes to `lib/` code
2. Add/update tests in `spec/unit/` for library changes
3. Add/update tests in `spec/integration/` for CLI changes
4. Run `mise run test` - must pass before committing
5. Fix any RuboCop offenses
6. Test cross-Ruby with `mise run test:matrix`
7. Commit with descriptive messages

## CLI tool usage

```bash
bundle exec pathspec-rb -f .gitignore match "file.swp"
bundle exec pathspec-rb -f .gitignore specs_match "file.swp"
bundle exec pathspec-rb -f .gitignore tree ./src
```

## Common issues

**Bundler conflicts**: Always use `mise run install` to ensure correct versions from `.tool-versions`

**RuboCop failures**: Auto-fix with `bundle exec rubocop --autocorrect`. Method length is common issue - extract large data arrays to separate methods with rubocop:disable comments

**CI failures**: Check GitHub Actions. RuboCop and integration test failures are most common causes

## Dependencies

- **Runtime**: None (pure Ruby)
- **Development**: rspec (~> 3.10), rubocop (~> 1.63.0), fakefs (~> 2.5), kramdown (~> 2.3), benchmark-ips (~> 2.0)