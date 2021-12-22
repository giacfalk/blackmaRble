# blackmaRble
blackmaRble: retrieve, wrangle and plot VIIRS Black Marble nighttimelight data in R

Since the release of the new Black Marble nighttime light data products based on VIIRS (see Roman et al. 2019 for details), there has been no easy way to access the data from the R scientific computing environment. Given the interest for the data manifested by a large number of researchers and practitioners from different disciplines, I developed a package to serve this purpose. 
Existing packages such as Rnightlights or opendapr either lack the black marble suite products, or are processing it in an inefficient way and not able to convert the data to a projected Raster or RasterStack object to handle with the conventional GIS functions in R.

## Installation

Install with:

``` r
library(devtools)
install_github("https://github.com/giacfalk/blackmaRble")
```
## Operation

Operate the package as follows, replacing username and password with your EarthData (https://urs.earthdata.nasa.gov/users/new) login data.

``` r
library(blackmaRble)
bm_initialize("username", "password")
bm_get_data( date_start="2019-09-15", date_end='2019-09-16', delta='days', data_product='VNP46A2', variable_name="Gap_Filled_DNB_BRDF_Corrected_NTL", custom_shape=NULL)
```
where:

-   date_start = first day of data to download
-   date_end = last day of data to download
-   delta = delta between dates; can be 'days', '2 days', 'months', 'years', etc. following conventions of `as.Date`
-   data_product = data product to download among the Black Marble suite products (e.g. VNP46A1, VNP46A2, or VNP46A3)
-   variable_name = variable to load (i.e. band of the nc file); depends on the data product considered. For a list see: 

https://ladsweb.modaps.eosdis.nasa.gov/missions-and-measurements/products/VNP46A1/
https://ladsweb.modaps.eosdis.nasa.gov/missions-and-measurements/products/VNP46A2/
https://ladsweb.modaps.eosdis.nasa.gov/missions-and-measurements/products/VNP46A3/

-   custom_shape = a custom `sf` simple feature polygon defining an area where to download and crop the data
