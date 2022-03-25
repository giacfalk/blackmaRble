#' @export
dl_func <- function(url, output, username, password) {
  httr::RETRY(verb = "GET", url, httr::authenticate(username, password),
              httr::write_disk(output, overwrite=T), times = 10)
}

#' @export
odr_login_bm <- function (credentials, source, verbose = TRUE)
{
  if (!inherits(credentials, "character") || length(credentials) !=
      2) {
    stop("credentials must be a vector character string of length 2 (username and password)\n")
  }
  .testInternetConnection()
  if (verbose) {
    cat("Checking credentials...\n")
  }
  if (source == "earthdata") {
    x <- httr::GET(url = "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.006/h17v07.ncml.ascii?time",
                   httr::authenticate(user = credentials[1], credentials[2]),
                   config = list(maxredirs = -1), timeout(30))
    httr::stop_for_status(x, "login to Earthdata. Check out username and password")
    httr::warn_for_status(x)
    options(earthdata_user = credentials[1])
    options(earthdata_pass = credentials[2])
    options(earthdata_odr_login = TRUE)
  }
  if (verbose) {
    cat("Successfull login to", source, "\n")
  }
}


#' @export
bm_initialize <- function(username, password){

require(sf)
require(stars)
require(raster)
require(ncdf4)
require(magrittr)
require(purrr)
library(scales)
library(tidyverse)
library(lubridate)
library(opendapr)
library(qdapRegex)
library(gtools)
library(rasterVis)

options(error = expression(NULL), warn=-1)

assign("username", username, envir = .GlobalEnv)
assign("password", password, envir = .GlobalEnv)

tiles <- read_sf(system.file("extdata", "BlackMarbleTiles.shp", package = "blackmaRble"))

assign("tiles", tiles, envir = .GlobalEnv)

}

