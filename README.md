<h2 align = "center">
Installation
</h2>

Fetch from CRAN using:
```r
install.packages("data.table.threads")
```
or use the latest (developmental) version from here:
```r
if(!require(remotes)) install.packages("remotes"); remotes::install_github("Anirban166/data.table.threads")
```
```r
if(!require(devtools)) install.packages("devtools"); devtools::install_github("Anirban166/data.table.threads")
```

<h2 align = "center">
Usage
</h2>

`findOptimalThreadCount(rowCount, columnCount, ...)` is the go-to function that runs a set of predefined benchmarks for various `data.table` functions that are parallelizable, across varying thread counts (iteratively from one to the highest number available as per the user's system). It involves computation to find the optimal/ideal speedup and thread count for each function. It returns a `data.table` object of a custom class (`print` and `plot` methods have been provided), which contains the optimal thread count for each function. It also provides plot data (consisting of speedup trends and key points) as attributes.
```r
> benchmarks <- data.table.threads::findOptimalThreadCount(1e7, 10, verbose = TRUE)
Running benchmarks with 1 thread, 10000000 rows, and 10 columns.
...
Running benchmarks with 10 threads, 10000000 rows, and 10 columns.
```
```r
> benchmarks
data.table function  Thread count Fastest median runtime (ms)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
forder               8            99.320183
GForce_sum           5            15.709294
subsetting           6            57.685606
frollmean            9            23.233573
fcoalesce            9            7.332542
between              8            21.947874
fifelse              5            19.284555
nafill               6            7.316102
CJ                   2            3.658697
```
The output here is a table which shows the fastest runtime (median value in milliseconds) for each applicable `data.table` function along with the corresponding thread count that achieved it.

Plotting this object would generate a plot that shows the ideal and measured speedup trends for each routine:
```r
> plot(benchmarkData)
```
<img width="100%" alt="plot image" src="https://github.com/user-attachments/assets/84a4e091-6649-4f17-98ea-ba6561fd920a"> <br>

If the user wants to factor in a specified speedup efficiency, they can use the function `addRecommendedEfficiency` to add a speedup line (with a slope configured by input argument `efficiencyFactor`; default value is 0.5, or 50% efficiency) along with a point representing the recommended thread count which stems from the highest intersection between this line (of specified thread-use efficiency) and measured speedup data for each function:
```r
benchmarks_r <- addRecommendedEfficiency(benchmarks, recommendedEfficiency = 0.4)
plot(benchmarks_r)
```
<img width = "100%" alt = "plot with specified efficiency data (lines and points) added" src = "https://github.com/user-attachments/assets/7ba2ae94-fa7e-4ea1-ad7a-1efb98f907f2"> <br>

In both cases (with our without the addition of recommended efficiency), the generated plot delineates the speedup across multiple threads (from 1 to the number of threads available in the user's system; 10 in my case here) for each function.

`setThreadCount(benchmarks, functionName, efficiencyFactor)` can then be used to set the thread count based on the observed results for a user-specified function and efficiency value (of the range [0, 1]) for the speedup:
```r
> setThreadCount(benchmarks_r, functionName = "forder", efficiencyFactor = 0.6, verbose = TRUE)
The number of threads that data.table will use has been set to 3, based on an efficiency factor of 0.6 for data.table::forder() based on the performed benchmarks.
> getDTthreads()
[1] 3
```
