
<!-- README.md is generated from README.Rmd. Please edit that file -->

# roadworksUK

The goal of roadworksUK is to enable you to access, process and visualis
data on UK roadworks, particularly Electronic Transfer of Notifications
(EToN)
records.

## Installation

<!-- You can install the released version of roadworksUK from [CRAN](https://CRAN.R-project.org) with: -->

Install the package hosted on [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ITSLeeds/roadworksUK")
```

Load the package with:

``` r
library(roadworksUK)
```

## What’s in the package?

There are a number of functions for processing EToN records, as shown
by:

``` r
x <- library(help = roadworksUK)
x$info[[2]]
#>  [1] "highway_authorities     Highway authorities"                            
#>  [2] "htdd_ashford            EtON roadworks data (raw HTDD logs from Elgin)" 
#>  [3] "msoa_ashford            msoa boundary data for ashford"                 
#>  [4] "road_stats              Road statistics for HAs"                        
#>  [5] "rw_clean                clean roadworks data"                           
#>  [6] "rw_clean_points         Clean Spatial Part of the HDDT Data"            
#>  [7] "rw_import_elgin_batch   Bulk Import Elgin road works data"              
#>  [8] "rw_import_elgin_ed      Import Elgin ED road works data"                
#>  [9] "rw_import_elgin_htdd    Import Elgin HDDT road works data"              
#> [10] "rw_import_elgin_restrictions"                                           
#> [11] "                        Import Elgin Restrictions road works data"      
#> [12] "rw_import_elgin_ttvdd   Import Elgin TTVDD road works data"             
#> [13] "rw_import_scot          Import Scottish road works data"                
#> [14] "rw_points_to_region     Match Points to Regions"                        
#> [15] "rw_spatial              Convert an data frame containing roadworks data"
#> [16] "                        into a spatial data object"                     
#> [17] "rw_spec_scottish        Scottish road works spec"
```

The datasets provided by the package include `kent10`, a minimal dataset
containing data from Kent, `htdd_ashford`, ~981 records from Ashford,
Kent. The characteristics of these datasets is demonstrated below:

``` r
data("htdd_ashford")
dim(htdd_ashford) # a larger dataset
#> [1] 981  90
htdd_ashford[1:3, 1:5]
#>           id entity_id item_id                works_ref project_ref
#> 446 38017881 105824835 4187672          EB006-M16861611            
#> 447 38017882 105824859 4187693              GE605218822            
#> 525 38017960 105860399 4211964 GE4000ENT000000058915491
```

``` r
file_path = system.file("extdata", "kent10.csv.gz", package = "roadworksUK")
file.exists(file_path)
#> [1] TRUE
htdd_example = rw_import_elgin_htdd(file_path = file_path)
ncol(htdd_example)
#> [1] 91
nrow(htdd_example) # a small dataset with 10 rows
#> [1] 10
```
