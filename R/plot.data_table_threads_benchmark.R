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
#' benchmarkData <- findOptimalThreadCount(1000, 10)
#' # Generating speedup plots based on the data collected above:
#' plot(benchmarkData)
#' }

plot.data_table_threads_benchmark <- function(x, ...)
{
  x[, `:=`(
    speedup = medianTime[threadCount == 1] / medianTime, 
    type = "Measured"
  ), by = expr]

  maxSpeedup <- x[, .(threadCount = threadCount[which.max(speedup)], speedup = max(speedup)), by = expr]

  idealSpeedup.list <- lapply(unique(x$expr), function(expr)
  {
    data.table(threadCount = 1:getDTthreads(),
               speedup = seq(1, getDTthreads()),
               expr = expr, type = "Ideal")
  })
  subOptimalSpeedup.list <- lapply(unique(x$expr), function(expr)
  {
    data.table(threadCount = seq(1, getDTthreads(), length.out = getDTthreads()),
               speedup = seq(1, getDTthreads()/2, length.out = getDTthreads()),
               expr = expr, type = "Sub-optimal")
  })

  combinedLineData <- rbindlist(c(idealSpeedup.list, subOptimalSpeedup.list, list(x)), use.names = TRUE, fill = TRUE)

  closestPoints <- x[, {
    suboptimalSpeedupSubset <- subOptimalSpeedup.list[[.GRP]][threadCount %in% .SD$threadCount, on = .(threadCount)]
    .SD[which.max(speedup - suboptimalSpeedupSubset$speedup)]
  }, by = expr]

  closestPoints[, `:=`(
    medianTime = NULL,
    type = "Recommended"
  )]
  maxSpeedup[, type := "Best performing"]
  combinedPointData <- rbind(maxSpeedup, closestPoints)

  ggplot(x, aes(x = threadCount, y = speedup)) +
    geom_line(data = combinedLineData, aes(x = threadCount, y = speedup, linetype = type), color = "black") +
    geom_point(data = combinedPointData, aes(x = threadCount, y = speedup, shape = type, color = type), size = 2) +
    geom_text(data = combinedPointData, aes(label = threadCount), vjust = -0.5, size = 4, na.rm = TRUE) +
    geom_ribbon(aes(ymin = speedup - 0.3, ymax = speedup + 0.3), alpha = 0.5) +
    facet_wrap(. ~ expr) +
    coord_equal() +
    labs(x = "Threads", y = "Speedup", title = "data.table functions", linetype = "Legend") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = 1:getDTthreads(), labels = 1:getDTthreads()) +
    scale_linetype_manual(values = c("Measured" = "solid", "Ideal" = "dashed", "Sub-optimal" = "dotted"), guide = "legend") +
    scale_shape_manual(values = c("Recommended" = 16, "Best performing" = 19), guide = "none") +
    scale_color_manual(values = c("Recommended" = "black", "Best performing" = "red")) +
    guides(linetype = guide_legend(override.aes = list(fill = NA), title = "Speedup"), color = guide_legend(override.aes = list(fill = NA), title = "Thread count"))
}