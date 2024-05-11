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

`data.table.threads::findOptimalThreadCount(rowCount, columnCount)` is the go-to function which runs a set of benchmarks for various `data.table` functions that are parallelizable. 
```r
> library(data.table.threads)
> benchmarkData <- findOptimalThreadCount(1e7, 10)
Running benchmarks with 1 thread, 10000000 rows, and 10 columns.
...
Running benchmarks with 10 threads, 10000000 rows, and 10 columns.
```
It returns an object with a class for which the print and plot methods have overridden definitions.
```r
> benchmarkData
data.table function  Fastest runtime (mean)  Thread count
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
between              25.945400               3           
CJ                   3.882732                5           
fcoalesce            8.787651                6           
fifelse              20.515229               6           
forder               90.870566               6           
frollmean            23.847375               8           
GForce_sum           15.725564               9           
nafill               8.240513                10          
subsetting           56.022399               10          
> plot(benchmarkData)
```
The output here is a table which shows the fastest runtime (mean value) for each `data.table` function along with the corresponding thread count that achieved it. 

<img width="100%" alt="plot image" src="https://github.com/Anirban166/data.table.threads/assets/30123691/3c5b55cc-c283-4711-948a-05a54ce5a592">

As for the generated plot, it delineates the speedup across multiple threads (from 1 to the number of threads available in your system; 10 in my case or this example) for each function.
