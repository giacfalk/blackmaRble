#' @export
bm_get_data <- function(date_start, date_end, delta, data_product, variable_name, custom_shape=NULL){

  if (is.null(custom_shape)){

    custom_shape <- read_sf(system.file("extdata", "kampala.gpkg", package = "blackmaRble"))


  } else {

custom_shape <- if (is.character(custom_shape)==TRUE){read_sf(custom_shape)} else{custom_shape}

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
  tryCatch({
  print(paste0("Downloading file ", i, " of ", nrow(df)*length(tile_index)))
  csv <- read_csv(paste0("https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/5000/", data_product, "/", df$year[i], "/", ifelse(nchar(df$yday[i])==1, paste0("00", df$yday[i]), ifelse(nchar(df$yday[i])==2, paste0("0", df$yday[i]), df$yday[i])), ".csv"), col_types = cols())

  file <- as.character(csv$name[grep(paste(tile_index,collapse="|"), csv$name)])

  for (j in 1:length(file)){

    link <- as.character(paste0("https://ladsweb.modaps.eosdis.nasa.gov/opendap/hyrax/allData/5000/", data_product, "/", as.character(df$year[i]), "/", as.character(ifelse(nchar(df$yday[i])==1, paste0("00", df$yday[i]), ifelse(nchar(df$yday[i])==2, paste0("0", df$yday[i]), df$yday[i]))),  "/", file[j], ".nc4"))

    dl_func(link, paste0(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\", paste0(file[j], ".nc4")), username, password)
  }  }, error=function(e){})
}

#

lista <- list.files(path=file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), pattern = "VNP46A2", full.names = T)
lista <- gtools::mixedsort(lista)
lista <- lista[sapply(lista, file.size) > 1000000]

vars <- lapply(lista, function(X){raster(X, varname=variable_name)})

tiles <- read_sf(system.file("extdata", "BlackMarbleTiles.shp", package = "blackmaRble"))

for (i in 1:length(vars)){
  print(i)
  tile_id <- ex_between(lista[i], ".", ".")[[1]][2]
  vars[[i]] <- crop(vars[[i]], extent(filter(tiles, TileID==tile_id)))
}

list_extents <- lapply(vars, extent)
list_extents <- lapply(list_extents, paste0)
list_extents <- unlist(list_extents)

s <- split(vars, list_extents)

vars_stack <- lapply(s, stack)

if (length(vars_stack)>1){

  names(vars_stack) <- NULL
  vars_stack <- do.call(raster::merge, vars_stack)
  vars_stack <- stack(vars_stack)

} else{

  vars_stack <- stack(vars_stack)

}

vars_stack <- stack(crop(vars_stack, extent(custom_shape)))
names(vars_stack) <- date_range

return(vars_stack)

}
