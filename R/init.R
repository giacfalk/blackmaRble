#' @export
dl_func <- function(url, output, username, password) {
  httr::RETRY(verb = "GET", url, httr::authenticate(username, password),
              httr::write_disk(output, overwrite=T))
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
library(rgis)
library(opendapr)
library(qdapRegex)

assign("username", username, envir = .GlobalEnv)
assign("password", password, envir = .GlobalEnv)

tiles <- read_sf(system.file("extdata", "BlackMarbleTiles.shp", package = "blackmaRble"))

assign("tiles", tiles, envir = .GlobalEnv)

}
