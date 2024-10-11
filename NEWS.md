# data.table.threads v1.0.0.

## New Features
- The data used for plotting (consisting of speedup trends/lines and key points) is now accessible via attributes of the `data.table` returned by `findOptimalThreadCount`.
- Added new arguments `verbose` and `times` to `runBenchmarks` and `findOptimalThreadCount`, allowing users to enable/disable detailed message printing and specify the number of benchmark repetitions.
- S3 `plot` method constructs a more intuitive `ggplot` for `data_table_threads_benchmark` class objects.
- Only user-facing functions are exported.
- Examples have been updated to use namespace qualification.
- Added a function to set the thread count for `data.table` operations based on recommended/optimal performance (in benchmarks) of a user-specified `data.table` function.

## Improvements
- Extensively refactored my codebase to remove redundancy.
- Made several optimizations (using `data.table` over `data.frame`, implementation of faster data aggregation operations, minimizing overhead for various function calls, etc.).
