#' Function that adds recommended efficiency speedup lines and points to benchmarks
#'
#' This function adds to the timing results (or the benchmarked data). It computes the recommended efficiency speedup line and the point which denotes the recommended thread count, both being based on the specified efficiency value.
#'
#' @param benchmarkData A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked results, which includes timings and speedup plot data (ideal and measured types) for each function.
#'
#' @param recommendedEfficiency A numeric value between 0 and 1 that defines the slope for the "Recommended" efficiency speedup line. (Default is 0.5)
#'
#' @return The input \code{data.table} with the recommended efficiency added to the plot data (attributes).
#'
#' @details This function allows users to add a "Recommended" efficiency line to previously computed benchmark data (without needing to recompute the timings). The recommended speedup is based on the provided efficiency value, which adjusts the slope of the speedup curve and correspondingly helps in the computation of the closest point of measured speedup to the "Recommended" speedup curve.
#'
#' @seealso \code{\link{findOptimalThreadCount}} for computing the benchmark data with measured and ideal speedup data.
#'
#' @export
#'
#' @examples
#' # Finding the best performing thread count for each benchmarked data.table function
#' # with a data size of 1000 rows and 10 columns:
#' benchmarks <- data.table.threads::findOptimalThreadCount(1e3, 10)
#' # Adding recommended efficiency to the plot data:
#' addRecommendedEfficiency(benchmarks, recommendedEfficiency = 0.6)

addRecommendedEfficiency <- function(benchmarkData, recommendedEfficiency = 0.5) 
{
  if(recommendedEfficiency <= 0 || recommendedEfficiency > 1)
  {
    stop("Recommended efficiency must be between 0 and 1.")
  }

  functions <- unique(benchmarkData$expr)
  systemThreadCount <- max(benchmarkData$threadCount)
  recommendedSpeedup <- seq(1, systemThreadCount * recommendedEfficiency, length.out = systemThreadCount)

  recommendedSpeedupData <- data.table(
    expr = rep(functions, each = systemThreadCount),
    threadCount = rep(seq(1, systemThreadCount), length(functions)),
    speedup = rep(recommendedSpeedup, length(functions)),
    type = "Recommended"
  )

  closestPoints <- benchmarkData[, {
    recommendedSubset <- recommendedSpeedupData[expr == .BY$expr & threadCount %in% .SD$threadCount]
    if(nrow(recommendedSubset) > 0) 
    {
      maxIndex <- which.max(.SD$speedup >= recommendedSubset$speedup)
      if(maxIndex > 0) .SD[maxIndex] else .SD[NA_integer_]
    } 
    else
    {
      .SD[NA_integer_]
    }
  }, by = expr]
  closestPoints[, type := "Recommended"]

  combinedLineData <- rbind(attr(benchmarkData, "lineData"), recommendedSpeedupData, fill = TRUE)
  combinedPointData <- rbind(attr(benchmarkData, "pointData"), closestPoints, fill = TRUE)

  setattr(benchmarkData, "lineData", combinedLineData)
  setattr(benchmarkData, "pointData", combinedPointData)
  benchmarkData
}