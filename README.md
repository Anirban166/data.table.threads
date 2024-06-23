<h2 align = "center">
Installation
</h2>

Use `devtools` or `remotes` to fetch the package from this repository:
```r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("Anirban166/data.table.threads")
```
```r
if(!require(remotes)) install.packages("remotes")
remotes::install_github("Anirban166/data.table.threads")
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
It returns an object with a class for which the print and plot methods have overridden definitions.
```r
> benchmarkData
data.table function  Thread count Fastest median runtime (ms)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
forder               10           85.401606              
GForce_sum           4            15.679425              
subsetting           6            53.844172              
frollmean            4            23.674446              
fcoalesce            7            7.365671               
between              5            22.730892              
fifelse              5            18.569536              
nafill               6            7.119630               
CJ                   2            3.403226        
```
The output here is a table which shows the fastest runtime (median value in milliseconds) for each `data.table` function along with the corresponding thread count that achieved it. 

```r
> plot(benchmarkData)
```
<img width="100%" alt="plot image" src="https://github.com/Rdatatable/data.table/assets/30123691/60496573-e52b-4085-8bc6-eddf809b0699"> <br>

As for the generated plot, it delineates the speedup across multiple threads (from 1 to the number of threads available in your system; 10 in my case or this example) for each function.

`setThreadCount(benchmarkData, functionName, efficiencyFactor)` can then be used to set the thread count based on the observed results for a user-specified function and efficiency value (of the range [0, 1]) for the speedup:
```r
> setOptimalThreadCount(benchmarks, "forder", 0)
The number of threads that data.table will use has been set to 10, the optimal thread count for data.table::forder() based on the performed benchmarks.
> getDTthreads()
[1] 10
```
