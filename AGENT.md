# AGENT.md

## PathSpec Ruby Development Guide

This document provides instructions for AI agents working with the pathspec-ruby project.

### Project Overview

PathSpec Ruby is a gem that implements .gitignore-style pattern matching in Ruby. It provides both a library API and a CLI tool for testing if files match gitignore patterns.

### Key Information

- **Language**: Ruby (3.2-4.0.1 supported)
- **Package Manager**: Bundler
- **Environment Manager**: mise
- **Test Framework**: RSpec
- **Linting**: RuboCop 1.63.5
- **CI/CD**: GitHub Actions (multi-Ruby matrix testing)

### Quick Setup

```bash
# Install mise (Ruby version manager)
# macOS
brew install mise
# Other platforms: https://mise.jdx.dev/getting-started.html

# Activate mise in shell
eval "$(mise activate zsh)"  # or bash, fish, etc.

# Install Ruby and bundler versions defined in .tool-versions
mise install

# Install gem dependencies
mise run install
# or: bundle install
```

### Essential Commands

**Testing:**
```bash
# Run all tests (rubocop, unit tests, integration tests, docs)
mise run test
# or: bundle exec rake

# Run only unit tests
mise run test:unit
# or: bundle exec rake spec

# Run only integration tests (CLI tests)
mise run test:integration
# or: bundle exec rake spec_integration

# Run all specs (unit + integration)
mise run test:all
# or: bundle exec rake spec_all

# Run tests across all Ruby versions using Docker
mise run test:matrix
# or: bundle exec rake test_matrix
```

**Code Quality:**
```bash
# Run RuboCop linter
mise exec ruby@3.4.1 -- bundle exec rubocop
# Or run via rake:
bundle exec rake rubocop

# Auto-fix RuboCop offenses
bundle exec rubocop --autocorrect
```

**Building:**
```bash
# Build the gem
mise run build
# or: gem build pathspec.gemspec

# Install from source (development build)
rake install
```

**Documentation:**
```bash
# Generate man page and HTML docs
bundle exec rake docs
# Generates docs/index.html and docs/man/pathspec-rb.man.1
```

### Project Structure

```
pathspec-ruby/
├── lib/pathspec/           # Core library code
│   ├── pathspec.rb       # Main PathSpec class
│   └── patterns/         # Pattern matching implementations
├── bin/pathspec-rb       # CLI executable
├── spec/
│   ├── unit/             # Unit tests for library code
│   └── integration/      # Integration tests for CLI
├── benchmarks/           # Performance benchmarks
├── docs/                # Documentation and man page source
├── Rakefile            # Build tasks and test definitions
├── .tool-versions       # Ruby/bundler versions for mise
└── pathspec.gemspec     # Gem specification
```

### Testing Strategy

1. **Unit Tests** (`spec/unit/`): Test PathSpec class and pattern matching logic
2. **Integration Tests** (`spec/integration/`): Test CLI functionality (`bin/pathspec-rb`)
3. **Linting**: RuboCop enforces code style
4. **Matrix Testing**: GitHub Actions tests across Ruby 3.2, 3.3, 3.4, and 4.0.1

### Common Issues & Solutions

**Bundler Version Conflicts:**
- The project uses specific Ruby and bundler versions defined in `.tool-versions`
- Always use mise to ensure correct versions
- If bundler version doesn't match `Gemfile.lock`, run: `mise run install`

**RuboCop Failures:**
- Method length limit is 69 lines
- Use single quotes for strings without interpolation
- Use `%w[]` for word arrays
- Auto-fix with: `bundle exec rubocop --autocorrect`
- For large data arrays, add: `# rubocop:disable Metrics/MethodLength`

**CI Failures:**
- Check GitHub Actions for matrix test failures
- RuboCop failures are common cause
- Integration test failures may indicate CLI issues

### Development Workflow

1. Make changes to library code in `lib/`
2. Add/update tests in `spec/unit/` for library changes
3. Add/update tests in `spec/integration/` for CLI changes
4. Run `mise run test` to ensure everything passes
5. Fix any RuboCop offenses
6. Test across multiple Ruby versions with `mise run test:matrix`
7. Commit changes with descriptive messages

### Key Dependencies

- **Runtime**: None (pure Ruby)
- **Development**: 
  - `rspec` (~> 3.10) - Testing
  - `rubocop` (~> 1.63.0) - Linting
  - `fakefs` (~> 2.5) - File system mocking for tests
  - `kramdown` (~> 2.3) - Documentation generation
  - `benchmark-ips` (~> 2.0) - Performance benchmarks

### Release Process

Maintainers can release via:
1. Update version in `pathspec.gemspec`
2. Update `CHANGELOG.md`
3. Commit changes and tag/release via GitHub UI
4. GitHub Actions will build and push to RubyGems

### Performance Considerations

- Benchmarks available in `benchmarks/pattern_scaling.rb`
- Tests performance with varying pattern counts
- Use `bundle exec ruby benchmarks/pattern_scaling.rb` to run

### CLI Tool

The `bin/pathspec-rb` executable provides:
- `match` - Test if a single path matches patterns
- `specs_match` - Show which patterns match a path
- `tree` - List all matching files in directory tree

Example usage:
```bash
bundle exec pathspec-rb -f .gitignore match "file.swp"
bundle exec pathspec-rb -f .gitignore tree ./src
```