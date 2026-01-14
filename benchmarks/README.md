# PathSpec Performance Benchmarks

This document describes the performance benchmarking methodology and results for the pathspec-ruby library.

## Methodology

The benchmarks measure pattern matching performance as the number of patterns increases. This is based on the approach used by [python-pathspec](https://github.com/cpburnz/python-pathspec/blob/master/benchmarks_backends.md).

### Test Configuration

- **Pattern counts tested**: 1, 5, 15, 25, 50, 100, 150 patterns
- **Test dataset**: 1000 representative file paths with varying directory depths and file extensions
- **Pattern types**: Mix of glob patterns, directory matches, negations, and complex wildcards
- **Warmup time**: 2 seconds per test
- **Benchmark time**: 5 seconds per test
- **Measurement**: Iterations per second (i/s) using the `benchmark-ips` gem

### Operations Benchmarked

1. **Single path matching**: Testing `match()` method on 10 individual paths
2. **Batch path matching**: Testing `match_paths()` method on 100 paths at once
3. **Pattern initialization**: Testing `PathSpec.new()` construction time

### Important Notes

- File system I/O is not tested; all paths are pre-generated in memory
- Patterns are representative of real-world `.gitignore` files
- Tests focus on GitIgnore-style patterns (the most common use case)
- Results show how performance scales with pattern complexity

## Running Benchmarks

To run the benchmarks on your system:

### Using mise (recommended)

```bash
# Run benchmarks directly
mise run benchmark
```

### Using rake directly

```bash
# Install dependencies (includes benchmark-ips gem)
bundle install

# Run benchmarks (this takes several minutes)
bundle exec rake benchmark
```

The benchmark task is **not** included in CI pipelines and should be run manually when needed.

## Results

### Hardware: Apple M4 Pro

**Specifications:**
- Processor: Apple M4 Pro
- Cores: 12 (8 performance + 4 efficiency)
- Memory: 24 GB RAM
- OS: macOS

**Ruby Version:** 3.4.1 (2024-12-25 revision 48d4efcb85) +PRISM [arm64-darwin25]

#### Single Path Matching Performance

Testing 10 individual path matches per iteration.

| Patterns | Iterations/sec | Relative to baseline | Time per iteration |
|----------|----------------|----------------------|--------------------|
| 1        | 442,619        | 1.0x                 | 2.26 μs            |
| 5        | 109,999        | 0.25x (4x slower)    | 9.09 μs            |
| 15       | 50,291         | 0.11x (8.8x slower)  | 19.88 μs           |
| 25       | 31,099         | 0.07x (14x slower)   | 32.16 μs           |
| 50       | 16,539         | 0.04x (27x slower)   | 60.46 μs           |
| 100      | 8,361          | 0.02x (53x slower)   | 119.61 μs          |
| 150      | 5,659          | 0.01x (78x slower)   | 176.71 μs          |

#### Batch Path Matching Performance (100 paths)

Testing `match_paths()` with 100 paths per iteration.

| Patterns | Iterations/sec | Relative to baseline | Time per iteration |
|----------|----------------|----------------------|--------------------|
| 1        | 1,458          | 1.0x                 | 686 μs             |
| 5        | 1,307          | 0.90x (1.1x slower)  | 765 μs             |
| 15       | 1,137          | 0.78x (1.3x slower)  | 879 μs             |
| 25       | 1,004          | 0.69x (1.5x slower)  | 996 μs             |
| 50       | 775            | 0.53x (1.9x slower)  | 1.29 ms            |
| 100      | 518            | 0.36x (2.8x slower)  | 1.93 ms            |
| 150      | 392            | 0.27x (3.7x slower)  | 2.55 ms            |

#### Pattern Initialization Performance

Testing `PathSpec.new()` construction time per iteration.

| Patterns | Iterations/sec | Relative to baseline | Time per iteration |
|----------|----------------|----------------------|--------------------|
| 1        | 285,824        | 1.0x                 | 3.50 μs            |
| 5        | 59,726         | 0.21x (4.8x slower)  | 16.74 μs           |
| 15       | 18,280         | 0.06x (16x slower)   | 54.71 μs           |
| 25       | 10,683         | 0.04x (27x slower)   | 93.60 μs           |
| 50       | 5,003          | 0.02x (57x slower)   | 199.88 μs          |
| 100      | 2,443          | 0.01x (117x slower)  | 409.33 μs          |
| 150      | 1,461          | 0.01x (196x slower)  | 684.60 μs          |

### Analysis

#### Performance Scaling Characteristics

1. **Linear to slightly super-linear degradation**: All three operations show performance degradation that's roughly proportional to pattern count, with initialization showing the steepest decline.

2. **Operation-specific impacts**:
   - **Initialization** is most affected: ~196x slower at 150 patterns (0.68ms vs 3.5μs)
   - **Single path matching**: ~78x slower at 150 patterns (177μs vs 2.3μs)
   - **Batch matching**: ~3.7x slower at 150 patterns (2.55ms vs 686μs) - most resilient

3. **Practical performance thresholds**:
   - **1-25 patterns**: Excellent performance for all operations (< 100μs for initialization)
   - **25-50 patterns**: Still very fast, suitable for most applications
   - **50-100 patterns**: Noticeable but acceptable performance (~400μs initialization)
   - **100+ patterns**: May be noticeable in tight loops or high-throughput scenarios

4. **Batch matching efficiency**: The `match_paths()` method shows the best scaling because it amortizes the pattern matching cost across multiple paths. Even with 150 patterns, it can process ~39,200 paths per second (392 iterations × 100 paths).

5. **Initialization vs matching trade-off**:
   - Single pattern initialization is very fast (3.5μs), making it viable to create PathSpec objects on-demand
   - With 100+ patterns, initialization cost becomes significant (~400μs), suggesting benefits from caching PathSpec objects
   - However, matching operations remain efficient enough for most use cases

6. **Real-world implications**:
   - Typical `.gitignore` files have 20-50 meaningful patterns: performance is excellent
   - Large enterprise `.gitignore` files with 100+ patterns: still sub-millisecond for most operations
   - For high-frequency matching (e.g., watching file systems), cache PathSpec objects rather than recreating

## Future Enhancements

Potential areas for future benchmarking:

1. **Pattern Complexity**: Compare simple glob patterns vs complex regex patterns
2. **Negation Overhead**: Test performance impact of `!` negation patterns
3. **Directory vs File Patterns**: Compare performance of patterns with trailing `/`
4. **Memory Profiling**: Track memory usage as pattern count increases
5. **Real-world Files**: Test against actual large `.gitignore` files from popular projects
6. **Tree Traversal**: Benchmark `match_tree()` on directory structures of varying sizes
7. **Pattern Types**: Compare GitIgnore vs Regex pattern performance
8. **Ruby Versions**: Compare performance across Ruby 3.2, 3.3, 3.4, and 4.0

## Contributing

When contributing benchmark results:

1. Always specify your hardware details (processor, cores, memory)
2. Include Ruby version used for testing
3. Run benchmarks multiple times to verify consistency
4. Note any significant background processes that might affect results
5. Update this README with your findings
