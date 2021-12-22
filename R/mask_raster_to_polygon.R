#' Fast masking of raster values
#'
#' This is a fast implementation of [raster::mask()]. It masks values in a Raster object according to values in another Raster or polygon layer. Note that this function might sometimes be slower than [raster::mask()] when the mask is a Raster. Largest speed gains occur for polygon masks.
#'
#' @param ras Raster* object.
#' @param mask Raster* object or POLYGON/MULTIPOLYGON [sf::sf()] object.
#' @param inverse Logical. If TRUE, areas in `mask` that are *not* NA are masked
#' @param updatevalue Convert all masked cells in `ras` to this value (default is NA)
#'
#' @return Raster* object
#' @export
#'
#' @seealso [raster::mask()]
#'
#' @examples
#' library(raster)
#'
#' size <- 100
#' ras <- raster(ncol = size, nrow = size, vals = rep(1, size*size))
#' msk <- raster(ncol = size, nrow = size, vals = runif(size*size))
#' msk[msk < 0.5] <- NA
#'
#' # Using raster as mask
#'
#' system.time(ras.masked <- raster::mask(ras, msk))
#' system.time(ras.masked <- fast_mask(ras, msk))
#'
#' plot(ras)
#' plot(msk)
#' plot(ras.masked)
#'
#'
#' # Using polygon layer as mask
#'
#' msk.sp <- as(msk, 'SpatialPolygonsDataFrame')
#' msk.sf <- sf::st_as_sf(msk.sp)
#' system.time(ras.masked <- raster::mask(ras, msk.sp))
#' system.time(ras.masked <- raster::mask(ras, msk.sf))
#' system.time(ras.masked <- fast_mask(ras, msk.sf))
#'
mask_raster_to_polygon <- function(ras = NULL, mask = NULL, inverse = FALSE, updatevalue = NA) {

  stopifnot(inherits(ras, "Raster"))

  stopifnot(inherits(mask, "Raster") | inherits(mask, "sf"))

  stopifnot(raster::compareCRS(ras, mask))


  ## If mask is a polygon sf, pre-process:

  if (inherits(mask, "sf")) {

    stopifnot(unique(as.character(sf::st_geometry_type(mask))) %in% c("POLYGON", "MULTIPOLYGON"))

    # First, crop sf to raster extent
    sf.crop <- suppressWarnings(sf::st_crop(mask,
                                            y = c(
                                              xmin = raster::xmin(ras),
                                              ymin = raster::ymin(ras),
                                              xmax = raster::xmax(ras),
                                              ymax = raster::ymax(ras)
                                            )))
    sf.crop <- sf::st_cast(sf.crop)

    # Now rasterize sf
    mask <- fasterize::fasterize(sf.crop, raster = ras)

  }



  if (isTRUE(inverse)) {

    ras.masked <- raster::overlay(ras, mask,
                                  fun = function(x, y)
                                  {ifelse(!is.na(y), updatevalue, x)})

  } else {

    ras.masked <- raster::overlay(ras, mask,
                                  fun = function(x, y)
                                  {ifelse(is.na(y), updatevalue, x)})

  }

  ras.masked

}
