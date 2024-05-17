#' Function to run a set of predefined benchmarks for different \code{data.table} functions with varying thread counts
#'
#' @param rowCount The number of rows in the \code{data.table}.
#'
#' @param colCount The number of columns in the \code{data.table}.
#'
#' @param threadCount The total number of threads to use.
#'
#' @return A \code{data.table} containing benchmarked timings for each \code{data.table} function with different thread counts.
#'
#' @details Benchmarks various \code{data.table} functions that are parallelizable (\code{setorder}, \code{GForce_sum}, \code{subsetting}, \code{frollmean}, \code{fcoalesce}, \code{between}, \code{fifelse}, \code{nafill}, and \code{CJ}) with varying thread counts.
#'
#' @export
#'
#' @import data.table
#' @import microbenchmark
#'
#' @examples
#' \dontrun{
#' # Running a set of benchmarks for a data.table with 1000 rows and 10 columns, for thread counts going from 1 to the maximum number of available threads in the user's system:
#' benchmarkData <- runBenchmarks(1000, 10, getDTthreads())
#' }

runBenchmarks <- function(rowCount, colCount, threadCount)
{
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

  benchmarkSummary <- summary(benchmarks)
  medianTime <- benchmarkSummary$median
  exprNames <- benchmarkSummary$expr

  data.table(threadCount = threadCount, expr = exprNames, medianTime = medianTime)
}