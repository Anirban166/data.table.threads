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
#' # Finding the best performing thread count for each benchmarked data.table function
#' # with a data size of 1000 rows and 10 columns:
#' benchmarkData <- data.table.threads::findOptimalThreadCount(1e3, 10)
#' # Generating speedup plots based on the data collected above:
#' plot(benchmarkData)

plot.data_table_threads_benchmark <- function(x, ...)
{
  benchmarkData <- x$benchmarkResults
  speedupTrends <- x$combinedLineData
  keyPlotPoints <- x$combinedPointData
  systemThreadCount <- max(benchmarkData$threadCount)
  
  benchmarkData[, `:=`(minSpeedup = min(speedup, na.rm = TRUE), maxSpeedup = max(speedup, na.rm = TRUE)), by = expr]
  
  ggplot(benchmarkData, aes(x = threadCount, y = speedup)) +
    geom_line(data = speedupTrends, aes(color = type), size = 1) +
    geom_point(data = keyPlotPoints, aes(color = type), size = 3) +
    geom_text(data = keyPlotPoints, aes(label = threadCount), vjust = -0.5, size = 4, na.rm = TRUE) +
    facet_wrap(. ~ expr) +
    coord_equal() +
    labs(x = "Threads", y = "Speedup", title = "data.table functions") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = 1:systemThreadCount, labels = 1:systemThreadCount) +
    scale_color_manual(values = c("Measured" = "black", "Ideal" = "#f79494", "Recommended" = "#93c4e0")) +
    guides(color = guide_legend(title = "Type"))
}
