#' Function to make speedup plots for the benchmarked \code{data.table} functions
#'
#' @param x A \code{data.frame} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
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

plot.data_table_threads_benchmark <- function(x, ...) {

  df <- x
  rownames(df) <- NULL
  df$speedup <- df$meanTime[df$threadCount == 1] / df$meanTime

  idealSpeedup <- seq(1, getDTthreads())
  setDT(df)
  maxSpeedup <- df[, .(threadCount = threadCount[which.max(speedup)], speedup = max(speedup)), by = expr]
  subOptimalSpeedup <- data.frame(x = seq(1, getDTthreads(), length.out = getDTthreads()), y = seq(1, getDTthreads()/2, length.out = getDTthreads()))
  intersection <- df[, .SD[which.min(abs(speedup - subOptimalSpeedup$y)) + which.min(abs(threadCount - subOptimalSpeedup$x))], by = expr]

  ggplot(df, aes(x = threadCount, y = speedup, linetype = "Legend")) +
    geom_line(aes(color = expr, linetype = "Measured Speedup")) +
    geom_line(data = data.frame(threadCount = 1:getDTthreads(), speedup = idealSpeedup), aes(x = threadCount, y = speedup, linetype = "Ideal Speedup"), color = "red") +
    geom_line(data = subOptimalSpeedup, aes(x, y, linetype = "Sub-optimal Speedup"), color = "blue") +
    geom_point(data = intersection, aes(x = threadCount, y = speedup), color = "black", size = 2) +
    geom_text(data = intersection, aes(label = threadCount), vjust = -0.5, size = 4, na.rm = TRUE) +
    geom_ribbon(aes(ymin = speedup - 0.3, ymax = speedup + 0.3), alpha = 0.5) +
    facet_wrap(. ~ expr) +
    coord_equal() +
    labs(x = "Threads", y = "Speedup", title = "data.table functions", linetype = "Legend") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = 1:getDTthreads(), labels = 1:getDTthreads()) +
    scale_color_manual(values = c("Speedup" = "black"), guide = "none") +
    scale_linetype_manual(values = c("Measured Speedup" = "solid", "Ideal Speedup" = "dashed", "Sub-optimal Speedup" = "dotted"), guide = "legend") +
    guides(linetype = guide_legend(override.aes = list(fill = NA)))
}
