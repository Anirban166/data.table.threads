#' Function to make speedup plots for the benchmarked \code{data.table} functions
#'
#' @param x A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param ... Additional arguments (not used in this function but included for consistency with the S3 generic \code{plot} function).
#'
#' @return A \code{ggplot} object containing a speedup plot for each benchmarked \code{data.table} function.
#'
#' @details Creates a comprehensive \code{ggplot} showing the ideal, sub-optimal, and measured speedup trends for the \code{data.table} functions benchmarked with varying thread counts.
#'
#' @export
#'
#' @import ggplot2
#' @import data.table
#'
#' @examples
#' \dontrun{
#' # Finding the best performing thread count for each benchmarked data.table function with a data size of 1000 rows and 10 columns:
#' benchmarkData <- data.table.threads::findOptimalThreadCount(1000, 10)
#' # Generating speedup plots based on the data collected above:
#' plot(benchmarkData)
#' }

plot.data_table_threads_benchmark <- function(x, ...)
{
  x[, `:=`(
    speedup = medianTime[threadCount == 1] / medianTime,
    type = "Measured"
  ), by = expr]

  maxSpeedup <- x[, .(threadCount = threadCount[which.max(speedup)],
                      speedup = max(speedup),
                      minTime = as.numeric(NA),
                      maxTime = as.numeric(NA),
                      medianTime = as.numeric(NA),
                      type = "Ideal"), by = expr]

  idealSpeedup <- x[, .(threadCount = 1:getDTthreads(),
                        speedup = seq(1, getDTthreads()),
                        type = "Ideal",
                        minTime = as.numeric(NA),
                        maxTime = as.numeric(NA),
                        medianTime = as.numeric(NA)), by = expr]

  subOptimalSpeedup <- x[, .(threadCount = seq(1, getDTthreads(), length.out = getDTthreads()),
                             speedup = seq(1, getDTthreads() / 2, length.out = getDTthreads()),
                             type = "Recommended",
                             minTime = as.numeric(NA),
                             maxTime = as.numeric(NA),
                             medianTime = as.numeric(NA)), by = expr]

  cols <- c("threadCount", "speedup", "type", "minTime", "maxTime", "medianTime", "expr")
  lapply(list(x, idealSpeedup, subOptimalSpeedup, maxSpeedup), setcolorder, cols)
  combinedLineData <- rbindlist(list(idealSpeedup, subOptimalSpeedup, x), use.names = TRUE, fill = TRUE)

  closestPoints <- x[, {
    suboptimalSpeedupSubset <- subOptimalSpeedup[expr == .BY$expr]
    .SD[.(threadCount = suboptimalSpeedupSubset$threadCount), on = .(threadCount), nomatch = 0L]
    .SD[which.max(speedup - suboptimalSpeedupSubset$speedup)]
  }, by = expr]

  closestPoints[, `:=`(
    minTime = as.numeric(NA),
    maxTime = as.numeric(NA),
    medianTime = as.numeric(NA),
    type = "Recommended"
  )]

  setcolorder(closestPoints, cols)
  combinedPointData <- rbindlist(list(maxSpeedup, closestPoints), use.names = TRUE, fill = TRUE)

  x[, `:=`(
    minSpeedup = min(speedup),
    maxSpeedup = max(speedup)
  ), by = expr]

  ggplot(x, aes(x = threadCount, y = speedup)) +
    geom_line(data = combinedLineData, aes(color = type), size = 1) +
    geom_point(data = combinedPointData, aes(color = type), size = 3) +
    geom_text(data = combinedPointData, aes(label = threadCount), vjust = -0.5, size = 4, na.rm = TRUE) +
    geom_ribbon(aes(ymin = minSpeedup, ymax = maxSpeedup), alpha = 0.5) +
    facet_wrap(. ~ expr) +
    coord_equal() +
    labs(x = "Threads", y = "Speedup", title = "data.table functions") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = 1:getDTthreads(), labels = 1:getDTthreads()) +
    scale_color_manual(values = c("Measured" = "black", "Ideal" = "#f79494", "Recommended" = "#93c4e0")) +
    guides(color = guide_legend(title = "Type"))
}