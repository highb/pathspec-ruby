# PathSpec Ruby Roadmap

This document outlines potential features and enhancements for the pathspec-ruby library. Items are organized by category and represent ideas for future development, not commitments or timelines.

## Additional Pattern Format Support

### Docker Ignore Patterns

Add support for `.dockerignore` files, which use a similar but slightly different syntax from `.gitignore`.

**Key differences:**
- Different handling of `**` at the start of patterns
- Exception patterns work differently than gitignore
- Docker-specific pattern matching semantics

**Implementation approach:**
- Add `PathSpec.from_dockerignore()` factory method
- Implement `DockerIgnoreSpec` class extending base `Spec`
- Document differences between Docker and Git pattern formats

**Use case:** Enable Docker users to validate and test their `.dockerignore` files programmatically.

---

### Mercurial Ignore Patterns

Add support for `.hgignore` files used by Mercurial VCS.

**Key features:**
- Support `syntax: regexp` directive for regex patterns
- Support `syntax: glob` directive for glob patterns
- Handle Mercurial-specific pattern semantics

**Implementation approach:**
- Add `PathSpec.from_hgignore()` factory method
- Parse and respect syntax directives within files
- Implement `HgIgnoreSpec` class with dual-mode support

**Use case:** Useful for polyglot VCS users and teams migrating between version control systems.

---

### NPM/Yarn Ignore Patterns

Add support for `.npmignore` and `.yarnignore` files with their subtle differences from gitignore.

**Key differences:**
- Different default exclusions (node_modules, etc.)
- Different handling of empty directories
- Package-specific matching behaviors

**Implementation approach:**
- Add `PathSpec.from_npmignore()` factory method
- Document default exclusions
- Handle package manager-specific semantics

**Use case:** Enable JavaScript/Node.js developers to validate package exclusions.

---

### Rsync Exclude Patterns

Add support for rsync's exclude pattern format (`.rsyncignore`).

**Key features:**
- Rsync has its own pattern syntax similar to gitignore but with differences
- Support for include/exclude pattern lists
- Support for merge-file directives

**Implementation approach:**
- Add `PathSpec.from_rsyncignore()` factory method
- Implement `RsyncIgnoreSpec` class
- Document rsync-specific pattern behaviors

**Use case:** Useful for deployment scripts and backup automation.

---

## Performance Enhancements

### Alternative Regex Backends

Implement support for high-performance regex engines as alternatives to Ruby's built-in regex.

**Potential backends:**
- **re2** - Google's RE2 engine via the `re2` gem (linear time matching, no backtracking)
- **Oniguruma** - Ruby's default regex engine, but could be used more explicitly
- **Hyperscan** - Intel's high-performance regex engine (if Ruby bindings become available)

**Implementation approach:**
- Add backend selection API: `PathSpec.new(patterns, :git, backend: :re2)`
- Benchmark each backend with the existing benchmark suite
- Document trade-offs (feature support vs. performance)
- Follow the pattern used by Python's pathspec library

**Benefits:**
- Significant performance improvements for pattern-heavy workloads
- Better performance scaling with 100+ patterns
- Reduced CPU usage in high-throughput scenarios

**Considerations:**
- Some backends may not support all Ruby regex features
- Additional gem dependencies required
- Cross-platform compatibility testing needed

---

### Pattern Compilation Caching

Add intelligent caching for compiled pattern objects.

**Features:**
- Cache compiled PathSpec objects by pattern set hash
- LRU eviction for memory management
- Thread-safe cache implementation

**Use case:** Applications that repeatedly create PathSpec objects with the same patterns.

---

## Experimental: Native Rust Backend

Explore adding an optional Rust-powered native extension using the `ignore` crate as an alternative backend to the pure Ruby implementation.

**Primary goal:** Learn Ruby/Rust FFI integration and gain hands-on experience with cross-language tooling.

**Secondary goal:** Understand performance characteristics and share findings with the community.

### Implementation Approach

**Phase 1: Separate gem exploration**
- Create standalone `pathspec-native` gem with Rust implementation
- Use the Rust `ignore` crate (from ripgrep) as the pattern matching engine
- Implement Ruby bindings using `magnus` or `rb-sys`
- Maintain 100% API compatibility with pathspec-ruby
- Benchmark extensively against pure Ruby implementation

**Phase 2: Optional integration (if Phase 1 succeeds)**
- Integrate as optional backend in main gem
- Maintain pure Ruby as default with automatic fallback
- Allow users to opt-in to native backend: `PathSpec.new(patterns, :git, backend: :native)`
- Ensure zero impact on users who don't want native dependencies

### Technical Considerations

**FFI tooling options:**
- **magnus** - Ruby bindings for Rust (modern, actively maintained)
- **rb-sys** - Low-level Ruby bindings (more control, more complexity)
- Compare both approaches and document trade-offs

**The `ignore` crate benefits:**
- Battle-tested in ripgrep (widely used, well-optimized)
- Supports .gitignore patterns natively
- High-performance parallel file tree walking
- Maintained by experienced Rust developer (BurntSushi)

**Cross-platform compilation:**
- Ensure builds work on Linux, macOS, Windows
- Set up CI/CD for automated native builds
- Consider pre-compiled gems for common platforms
- Document local build requirements

### Goals

1. **Learning outcomes:**
   - Understand Ruby C extension API vs. Rust FFI approaches
   - Learn `magnus`/`rb-sys` tooling and best practices
   - Experience cross-platform native gem distribution

2. **Performance insights:**
   - Benchmark native vs. Ruby across different workload sizes
   - Identify when native implementation provides benefits
   - Measure memory usage differences
   - Test with real-world .gitignore files (1, 10, 100, 1000+ patterns)

3. **Community contribution:**
   - Write detailed blog post about findings
   - Share performance data and methodology
   - Document FFI integration lessons learned
   - Provide reusable example for other gem authors

4. **Maintain pure Ruby as first-class:**
   - Pure Ruby version remains the default
   - No degradation of pure Ruby implementation
   - Native backend is purely additive

### Success Criteria

- ✅ Native extension compiles successfully on Linux, macOS, and Windows
- ✅ 100% API compatibility - drop-in replacement for pure Ruby backend
- ✅ Comprehensive benchmark suite comparing both implementations
- ✅ Documented performance characteristics with clear guidance
- ✅ CI/CD pipeline builds and tests native extensions
- ✅ Clear installation instructions for native dependencies
- ✅ Published blog post with findings and recommendations

### Non-Goals

**This is explicitly NOT:**
- A rewrite of the gem - pure Ruby implementation stays and remains primary
- A required dependency - native extension is optional only
- A response to performance complaints - this is exploratory learning
- A commitment to long-term maintenance of native code
- An attempt to deprecate the Ruby implementation

**What we're NOT optimizing for:**
- Absolute maximum performance - learning is the priority
- Production-critical performance - pure Ruby is already fast enough
- Replacing other tools - this is about understanding trade-offs

### Open Questions

Questions to answer through exploration:

1. **Performance questions:**
   - At what pattern count does native backend become beneficial?
   - How does performance scale with directory tree size?
   - What's the FFI call overhead for small workloads?
   - Is parallel tree walking worth the complexity?

2. **Developer experience questions:**
   - How painful is cross-platform native gem distribution?
   - What's the learning curve for magnus vs. rb-sys?
   - How do we handle build failures gracefully?
   - What's the maintenance burden of native code?

3. **User experience questions:**
   - Is opt-in vs. opt-out the right choice?
   - How do we communicate when native backend is beneficial?
   - What happens when native extension fails to load?
   - Should we pre-compile for common platforms?

### Potential Outcomes

**Best case:**
- Learn valuable FFI skills
- Discover significant performance benefits for certain workloads
- Share useful findings with community
- Provide optional native backend for power users

**Realistic case:**
- Learn valuable FFI skills
- Find that pure Ruby is "fast enough" for most use cases
- Discover native backend helps only for extreme workloads (1000+ patterns)
- Document when native extensions are/aren't worth it

**Acceptable case:**
- Learn valuable FFI skills
- Conclude that FFI overhead negates performance benefits
- Decide not to integrate into main gem
- Share lessons learned in blog post

All outcomes are valuable because the primary goal is learning.

### Resources & References

- **Rust `ignore` crate**: https://docs.rs/ignore/
- **magnus (Ruby ↔ Rust)**: https://github.com/matsadler/magnus
- **rb-sys**: https://github.com/oxidize-rb/rb-sys
- **ripgrep** (uses `ignore` crate): https://github.com/BurntSushi/ripgrep
- **Rust native extensions guide**: https://github.com/oxidize-rb/oxidize-rb

---

## Pattern Validation & Quality

### Pattern Linting and Validation

Add tools to check patterns for common mistakes and suggest improvements.

**Features:**

1. **Syntax error detection:**
   - Invalid glob patterns (e.g., `*.txt/` - wildcard with trailing slash)
   - Malformed bracket expressions
   - Escaped characters in wrong contexts

2. **Semantic warnings:**
   - Patterns that can never match (e.g., `/foo` when matching relative paths)
   - Redundant patterns (e.g., `*.log` followed by `error.log`)
   - Overly broad patterns that might match unintended files

3. **Performance suggestions:**
   - Recommend more efficient pattern ordering
   - Suggest combining similar patterns
   - Identify expensive regex patterns

4. **Style recommendations:**
   - Inconsistent path separator usage
   - Unnecessary escaping
   - Patterns that could be simplified

**Implementation approach:**
- Add `PathSpec#validate` method returning array of issues
- Implement `PathSpec::Linter` class with configurable rules
- Provide severity levels (error, warning, info)
- Include suggested fixes where applicable

**API example:**
```ruby
pathspec = PathSpec.from_filename('.gitignore')
issues = pathspec.validate

issues.each do |issue|
  puts "#{issue.severity}: #{issue.message}"
  puts "  Pattern: #{issue.pattern}"
  puts "  Suggestion: #{issue.suggestion}" if issue.suggestion
end
```

**Use case:** Help developers write better ignore files and catch mistakes before they cause issues.

---

### Pattern Testing Framework

Add utilities to test pattern matching behavior.

**Features:**
- Assert that specific paths match/don't match
- Generate test paths from patterns
- Coverage analysis (which patterns are actually being used)

**Use case:** CI/CD pipelines that verify ignore patterns work as expected.

---

## Advanced Filtering Features

### Case-Insensitive Matching

Add optional flag for case-insensitive pattern matching.

**Implementation approach:**
- Add `case_sensitive` option to PathSpec constructor
- Default to true (current behavior) for backwards compatibility
- Convert patterns to case-insensitive regexes when disabled

**API example:**
```ruby
# Match *.TXT, *.txt, *.Txt, etc.
pathspec = PathSpec.new(['*.txt'], :git, case_sensitive: false)
```

**Use case:** Cross-platform projects where case sensitivity varies (Windows vs. Linux/macOS).

---

### Attribute-Based Filtering

Extend pattern matching beyond filenames to include file attributes.

**Features:**

1. **File size patterns:**
   - `size:>10MB` - Files larger than 10MB
   - `size:<1KB` - Files smaller than 1KB
   - `size:100KB..10MB` - Files in size range

2. **Modification time patterns:**
   - `modified:>7d` - Modified in last 7 days
   - `modified:<2023-01-01` - Modified before date
   - `modified:today` - Modified today

3. **File permission patterns:**
   - `mode:executable` - Executable files
   - `mode:0644` - Specific permission mode
   - `mode:user-writable` - Files writable by owner

4. **File type patterns:**
   - `type:symlink` - Symbolic links
   - `type:directory` - Directories
   - `type:file` - Regular files

**Implementation approach:**
- Add `PathSpec#match_tree_with_attrs` method
- Create `AttributeSpec` class for attribute-based filtering
- Support combining path patterns with attribute filters

**API example:**
```ruby
pathspec = PathSpec.new(['*.log', 'size:>100MB'], :git)
large_logs = pathspec.match_tree('logs/')
```

**Use case:** Clean up scripts, archival tools, security audits.

---

### Glob Expansion

Add ability to expand glob patterns into matching file lists without needing a root directory.

**Features:**
- Generate all possible matches for a pattern
- Useful for testing and documentation
- Support limiting depth and count

**Use case:** Pattern documentation, test generation, interactive explorers.

---

## API Enhancements

### Streaming API

Add support for processing large file lists without loading everything into memory.

**Implementation approach:**
- Add `PathSpec#match_stream` that yields matches
- Support lazy evaluation with Enumerator
- Optimize for large directory trees

**API example:**
```ruby
pathspec = PathSpec.from_filename('.gitignore')
pathspec.match_stream('huge_directory/') do |matched_path|
  process(matched_path)
end
```

**Use case:** Large repositories, file system indexing, backup tools.

---

### Pattern Introspection

Add methods to analyze and understand pattern behavior.

**Features:**
- List all patterns that would match a given path
- Explain why a path matched (which pattern, why)
- Extract pattern metadata (complexity, type, etc.)

**API example:**
```ruby
pathspec = PathSpec.from_filename('.gitignore')
explanation = pathspec.explain('coverage/index.html')
# => "Matched by pattern 'coverage/' at line 15 (directory match)"
```

**Use case:** Debugging ignore rules, understanding complex ignore files.

---

### Pattern Composition

Add utilities to combine multiple PathSpec objects with set operations.

**Features:**
- Union: Match if any PathSpec matches
- Intersection: Match only if all PathSpecs match
- Difference: Match first PathSpec but not second

**API example:**
```ruby
gitignore = PathSpec.from_filename('.gitignore')
dockerignore = PathSpec.from_filename('.dockerignore')

# Files ignored by git OR docker
either = gitignore.union(dockerignore)

# Files ignored by git but NOT by docker
git_only = gitignore.difference(dockerignore)
```

**Use case:** Complex filtering logic, comparing ignore files.

---

## Testing & Quality

### Compatibility Test Suite

Add comprehensive tests against reference implementations.

**Features:**
- Test against git's actual ignore behavior
- Test against docker's ignore behavior
- Cross-reference with Python pathspec library
- Generate compatibility reports

**Use case:** Ensure accuracy and find edge cases.

---

### Property-Based Testing

Add property-based tests using the `rspec-propcheck` gem.

**Features:**
- Generate random patterns and paths
- Verify invariants hold for all inputs
- Find edge cases automatically

**Use case:** Improve robustness and find bugs.

---

## Documentation & Tooling

### Interactive Pattern Tester

Create a CLI tool or web interface for testing patterns interactively.

**Features:**
- Live pattern editing with instant feedback
- Visual highlighting of matches
- Pattern explanation and suggestions
- Save/load pattern sets

**Use case:** Learning, debugging, pattern development.

---

### Pattern Migration Tools

Add utilities to convert between different pattern formats.

**Features:**
- Convert gitignore to dockerignore
- Convert rsync excludes to gitignore
- Highlight patterns that don't translate cleanly

**Use case:** Migrating between tools, maintaining consistency.

---

## Contributing

This roadmap is a living document. If you'd like to:
- Propose new features
- Discuss implementation approaches
- Contribute implementations

Please open an issue or pull request on GitHub to start the conversation.

---

## Prioritization Considerations

When evaluating which features to implement, consider:

1. **User impact** - How many users would benefit?
2. **Maintenance burden** - How much ongoing maintenance is required?
3. **Compatibility** - Does it maintain backwards compatibility?
4. **Dependencies** - Does it require new dependencies?
5. **Complexity** - How complex is the implementation?
6. **Standards compliance** - Does it follow established standards?

Features that provide high user value with manageable complexity and maintenance burden should be prioritized.
