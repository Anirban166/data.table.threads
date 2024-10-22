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

`findOptimalThreadCount(rowCount, columnCount)` is the go-to function which runs a set of benchmarks for various `data.table` functions that are parallelizable. 
```r
> benchmarkData <- data.table.threads::findOptimalThreadCount(1e7, 10)
Running benchmarks with 1 thread, 10000000 rows, and 10 columns.
...
Running benchmarks with 10 threads, 10000000 rows, and 10 columns.
```
It returns an object with print and plot methods.
```r
> benchmarkData
data.table function  Thread count Fastest median runtime (ms)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
forder               8            82.736011              
GForce_sum           6            15.670897              
subsetting           6            54.386931              
frollmean            6            23.329410              
fcoalesce            5            7.319135               
between              6            22.716911              
fifelse              10           18.825437              
nafill               10           7.006490               
CJ                   1            3.194330        
```
The output here is a table which shows the fastest runtime (median value in milliseconds) for each `data.table` function along with the corresponding thread count that achieved it. 

```r
> plot(benchmarkData)
```
<img width="100%" alt="plot image" src="https://github.com/user-attachments/assets/dbb41dab-47ae-4132-8df6-59a23571cff3"> <br>

As for the generated plot, it delineates the speedup across multiple threads (from 1 to the number of threads available in your system; 10 in my case or this example) for each function.

`setThreadCount(benchmarkData, functionName, efficiencyFactor)` can then be used to set the thread count based on the observed results for a user-specified function and efficiency value (of the range [0, 1]) for the speedup:
```r
> setOptimalThreadCount(benchmarks, functionName = "forder", efficientcyFactor = 0.5, verbose = TRUE)
The number of threads that data.table will use has been set to 3, based on an efficiency factor of 0.5 for data.table::forder() based on the performed benchmarks.
> getDTthreads()
[1] 3
```
