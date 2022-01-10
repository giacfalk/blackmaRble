# blackmaRble

blackmaRble: retrieve, wrangle and plot VIIRS Black Marble nighttimelight data in R

<p align="center">
<img src="https://raw.githubusercontent.com/giacfalk/blackmaRble/main/logo.png" alt="" width="300"/>
</p>


## Background

<div style="text-align: justify">
Since the release of the new Black Marble nighttime light data products based on VIIRS [Roman et al. 2019](https://www.sciencedirect.com/science/article/pii/S003442571830110X), there has been no easy way to access the data from the R scientific computing environment. Given the interest for the data manifested by a large number of researchers and practitioners from different disciplines, I developed a package to serve this purpose. 

Existing packages such as [`Rnightlights`](https://github.com/chrisvwn/Rnightlights) or [`opendapr`](https://github.com/ptaconet/opendapr)  either lack the Black Marble suite products, or are processing it in an inefficient way and not able to convert the data to a projected Raster or RasterStack object to handle with the conventional GIS functions in R.
</div>

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
output <- bm_get_data( date_start="2019-09-15", date_end='2019-09-16', delta='days', data_product='VNP46A2', variable_name="Gap_Filled_DNB_BRDF_Corrected_NTL", custom_shape=NULL)
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

## Example

The resulting data is a regular RasterStack object, as seen by running `output`:

``` r
> output
class      : RasterStack 
dimensions : 73, 108, 7884, 2  (nrow, ncol, ncell, nlayers)
resolution : 0.004166666, 0.004166667  (x, y)
extent     : 32.37917, 32.82917, 0.1500007, 0.4541673  (xmin, xmax, ymin, ymax)
crs        : +proj=longlat +datum=WGS84 +no_defs 
names      : X2019.09.15, X2019.09.16 
min values :           0,           0 
max values :        75.8,        75.8 
```

and plotting the object with `bm_plot(output)`:

<p align="center">
<img src="https://raw.githubusercontent.com/giacfalk/blackmaRble/main/plot_example.png" alt="" width="600"/>
</p>

## Disclaimer

This package is developed by a data user, and is thus not linked or endorsed in any way by NASA or the Black Marble data proudct development team. Whilst the primary data quality does not depend on the blackmaRble package, any residual coding error affecting the data output remains the sole responsibility of the package maintainer. 
