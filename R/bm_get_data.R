#' @export
bm_get_data <- function(date_start, date_end, delta, data_product, variable_name, custom_shape=NULL){

  if (is.null(custom_shape)){

    custom_shape <- read_sf(system.file("extdata", "kampala.gpkg", package = "blackmaRble"))


  } else {

custom_shape <- read_sf(custom_shape)

  }


assign("date_start", date_start, envir = .GlobalEnv)
assign("date_end", date_end, envir = .GlobalEnv)
assign("delta", delta, envir = .GlobalEnv)
assign("data_product", data_product, envir = .GlobalEnv)
assign("variable_name", variable_name, envir = .GlobalEnv)
assign("custom_shape", custom_shape, envir = .GlobalEnv)

tiles <- st_filter(tiles, custom_shape, .predicate = st_intersects)
tile_index <- unique(tiles$TileID)

log <- odr_login(credentials = c(username,password), source = "earthdata")

options(download.file.method="libcurl", url.method="libcurl")

date_range <- seq(as.Date(date_start), as.Date(date_end), by = delta)
year <- lubridate::year(date_range)
month<- lubridate::month(date_range)
day <- lubridate::day(date_range)
yday <- lubridate::yday(date_range)

df <- data.frame(date_range, year, month, day, yday)

for (i in 1:nrow(df)){
  print(paste0("Downloading file ", i, " of ", nrow(df)*length(tile_index)))
  csv <- read_csv(paste0("https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/5000/", data_product, "/", df$year[i], "/", df$yday[i], ".csv"), col_types = cols())

  file <- as.character(csv$name[grep(paste(tile_index,collapse="|"), csv$name)])

  for (j in 1:length(file)){

    link <- as.character(paste0("https://ladsweb.modaps.eosdis.nasa.gov/opendap/hyrax/allData/5000/", data_product, "/", as.character(df$year[i]), "/", as.character(df$yday[i]),  "/", file[j], ".nc4"))

    dl_func(link, paste0(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\", paste0(file[j], ".nc4")), username, password)
  }}

#

lista <- list.files(path=file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), pattern = "VNP46A2", full.names = T)
lista <- gtools::mixedsort(lista)

vars <- lapply(lista, function(X){raster(X, varname=variable_name)})

tiles <- read_sf(system.file("extdata", "BlackMarbleTiles.shp", package = "blackmaRble"))

for (i in 1:length(vars)){
  print(i)
  tile_id <- ex_between(lista[i], ".", ".")[[1]][2]
  extent(vars[[i]]) <- extent(filter(tiles, TileID==tile_id))
  vars[[i]] <- mask_raster_to_polygon(vars[[i]], custom_shape)
}

list_extents <- lapply(vars, extent)
list_extents <- lapply(list_extents, paste0)
list_extents <- unlist(list_extents)

s <- split(vars, list_extents)

vars_stack <- lapply(s, stack)

vars_stack <- stack(vars_stack)

return(vars_stack)

}