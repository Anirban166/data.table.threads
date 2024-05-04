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

benchmarkData <- find_optimal_threads(10000000, 10)

rownames(benchmarkData) <- NULL
benchmarkData$speedup <- benchmarkData$meanTime[benchmarkData$threadCount == 1] / benchmarkData$meanTime

idealSpeedup <- seq(1, getDTthreads())
setDT(benchmarkData)
maxSpeedup <- benchmarkData[, .(threadCount = threadCount[which.max(speedup)], speedup = max(speedup)), by = expr]

ggplot(benchmarkData, aes(x = threadCount, y = speedup, color = expr)) +
  geom_line() +
  geom_line(data = data.frame(threadCount = 1:getDTthreads(), speedup = idealSpeedup), aes(x = threadCount, y = speedup), linetype = "dashed", color = "red") +
  geom_point(data = maxSpeedup, aes(x = threadCount, y = speedup), color = "black", size = 2) +
  facet_grid(. ~ expr, scales = "free_y") +
  labs(x = "Threads", y = "Speedup", title = "data.table functions") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_continuous(breaks = 1:getDTthreads(), labels = 1:getDTthreads())
