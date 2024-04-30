library(ggplot2)
library(data.table)
library(microbenchmark)

run_benchmarks <- function(rowCount, colCount, threadCount) {
  setDTthreads(threadCount)
  dt <- data.table(matrix(runif(rowCount * colCount), nrow = rowCount, ncol = colCount))
  threadLabel <- ifelse(threadCount == 1, "thread", "threads")
  
  cat(sprintf("Running benchmarks with %d %s, %d rows, and %d columns.\n", getDTthreads(), threadLabel, rowCount, colCount))
  
  benchmarks <- microbenchmark(
    forder = setorder(dt, V1),
    GForce_sum = dt[, .(sum(V1))],
    subsetting = dt[dt[[1]] > 0.5, ],
    frollmean = frollmean(dt[[1]], 10),
    fcoalesce = fcoalesce(dt[[1]], dt[[2]]),
    fifelse = fifelse(dt[[1]] > 0.5, dt[[1]], 0),
    between = dt[dt[[1]] %between% c(0.4, 0.6)],
    nafill = nafill(dt[[1]], type = "const", fill = 0),
    subsetting_column_intensive = dt[, .SD, .SDcols = 1:min(1000, colCount)],
    CJ = CJ(sample(rowCount, size = min(rowCount, 5)), sample(colCount, size = min(colCount, 5))),
    times = 100
  )
  
  benchmark_summary <- summary(benchmarks)
  meanTime <- benchmark_summary$mean
  names(meanTime) <- benchmark_summary$expr
  return(list(meanTime = meanTime, timings = benchmarks))
}

find_optimal_threads <- function(rowCount, colCount) {
  setDTthreads(0)
  maxThreads <- getDTthreads()
  results <- list()
  
  for (threadCount in 1:maxThreads) {
    results[[threadCount]] <- run_benchmarks(rowCount, colCount, threadCount)
  }
  
  optimal_threads <- sapply(names(results[[1]]$meanTime), function(fn) {
    times <- sapply(results, function(res) res$meanTime[fn])
    fastest <- which.min(times)
    list(optimal_thread = fastest, timing = results[[fastest]]$meanTime[fn])
  })
  
  names(optimal_threads) <- names(results[[1]]$meanTime)
  
  return(optimal_threads)
}

benchmarkData <- find_optimal_threads(10000000, 10)
attributes(benchmarkData)$names <- NULL

benchmark_df <- as.data.frame(t(benchmarkData))

benchmark_df$optimal_thread <- unlist(benchmark_df$optimal_thread)
benchmark_df$timing <- unlist(benchmark_df$timing)

benchmark_df$expr <- rownames(benchmark_df)
rownames(benchmark_df) <- NULL

ggplot(benchmark_df, aes(x = expr, y = timing, fill = factor(optimal_thread))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "data.table function", y = "Runtime", fill = "Threads") +
  ggtitle("Optimal thread count for data.table routines on your system") +
  theme_minimal() +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45, hjust = 1))
