#' Function to run a set of predefined benchmarks for different \code{data.table} functions with varying thread counts
#'
#' @param rowCount The number of rows in the \code{data.table}.
#'
#' @param colCount The number of columns in the \code{data.table}.
#'
#' @param threadCount The total number of threads to use.
#'
#' @param times The number of times the benchmarks are to be run.
#'
#' @param verbose Option (logical) to enable or disable detailed message printing.
#'
#' @param benchmarksList A named list of custom benchmarking functions which when specified overrides the default benchmarks for each parallelizable \code{data.table} routine. Each function must accept a \code{data.table} as its first argument and return a result.
#'
#' @param customDT A user-specified \code{data.table} that should contain all columns required by the functions in \code{benchmarksList}. Defaults to \code{NULL}, in which case a matrix \code{data.table} is generated internally using \code{rowCount} and \code{colCount}.
#'
#' @return A \code{data.table} containing benchmarked timings for each \code{data.table} function with different thread counts.
#'
#' @details Benchmarks various \code{data.table} functions that are parallelizable (\code{setorder}, \code{GForce_sum}, \code{subsetting}, \code{frollmean}, \code{fcoalesce}, \code{between}, \code{fifelse}, \code{nafill}, and \code{CJ}) with varying thread counts.
#'
#' @import data.table
#' @import microbenchmark
#' 
#' @importFrom stats runif

runBenchmarks <- function(rowCount, colCount, threadCount, times = 10, verbose = TRUE, benchmarksList = NULL, customDT = NULL)
{
  setDTthreads(threadCount)
  dt <- if(!is.null(customDT)) customDT else data.table(matrix(runif(rowCount * colCount), nrow = rowCount, ncol = colCount))

  threadLabel <- ifelse(threadCount == 1, "thread", "threads")
  if(verbose)
  {
    cat(sprintf("Running benchmarks with %d %s, %d rows, and %d columns.\n", getDTthreads(), threadLabel, nrow(dt), ncol(dt)))
  }

  if(is.null(benchmarksList))
  {
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
      times = times
    )
  }
  else
  {
    benchmarkExpressions <- setNames(lapply(benchmarksList, function(f) substitute(f(dt), list(f = f, dt = dt))), names(benchmarksList))
    benchmarks <- do.call(microbenchmark, c(benchmarkExpressions, list(times = times)))
  }
  data.table(threadCount, summary(benchmarks))
}
