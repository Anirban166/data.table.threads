library(ggplot2)
library(gridExtra)
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
    between = dt[dt[[1]] %between% c(0.4, 0.6)],
    fifelse = fifelse(dt[[1]] > 0.5, dt[[1]], 0),
    nafill = nafill(dt[[1]], type = "const", fill = 0),
    CJ = CJ(sample(rowCount, size = min(rowCount, 5)), sample(colCount, size = min(colCount, 5))),
    times = 100
  )

  benchmark_summary <- summary(benchmarks)
  meanTime <- benchmark_summary$mean
  names(meanTime) <- benchmark_summary$expr

  return(data.frame(threadCount = threadCount, expr = names(meanTime), meanTime = meanTime))
}

find_optimal_threads <- function(rowCount, colCount) {

  setDTthreads(0)
  maxThreads <- getDTthreads()
  results <- list()

  for (threadCount in 1:maxThreads) {
    results[[threadCount]] <- run_benchmarks(rowCount, colCount, threadCount)
  }

  return(do.call(rbind, results))
}

benchmarkData <- find_optimal_threads(1000, 10)

rownames(benchmarkData) <- NULL
benchmarkData$speedup <- benchmarkData$meanTime[benchmarkData$threadCount == 1] / benchmarkData$meanTime

idealSpeedup <- seq(1, getDTthreads())

plots <- lapply(unique(benchmarkData$expr), function(func) {
  data <- benchmarkData[benchmarkData$expr == func, ]
  ggplot(data, aes(x = threadCount, y = speedup)) +
    geom_line() +
    geom_line(aes(x = idealSpeedup, y = idealSpeedup), linetype = "dashed", color = "red") +
    labs(title = paste(func), x = "Threads", y = "Speedup") +
    theme(plot.title = element_text(hjust = 0.5)) +
    # To avoid the default numbering that includes 2.5 and 7.5: (half a thread doesn't make sense)
    scale_x_continuous(breaks = 1:getDTthreads(), labels = 1:getDTthreads())
})

grid.arrange(grobs = plots)
