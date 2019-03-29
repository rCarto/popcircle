#' @title Proportional Circles and Shapes
#' @name popcircle
#' @description Get proportional circles and polygons on a compact layout.
#' @param x an sf POLYGON or MULTIPOLYGON object
#' @param var name of the numeric field in x to get proportionalities.
#' @return A list of length 2 of circles and shapes sf objects.
#' @export
#' @import packcircles
#' @import sf
#' @examples
#' library(sf)
#' library(popcircle)
#' mtq <- st_read(system.file("gpkg/mtq.gpkg", package="popcircle"))
#' res <- popcircle(x = mtq, var = "POP")
#' circles <- res$circles
#' shapes <- res$shapes
#' par(mar = c(0,0,0,0))
#' plot(st_geometry(circles), col = "darkseagreen", border = "darkseagreen1")
#' plot(st_geometry(shapes), col = "red", add = TRUE, lwd = 1, border = "red4")
#' if(require(cartography)){
#'   labelLayer(x = circles[1:10,], txt = "LIBGEO", halo = TRUE, overlap = FALSE)
#' }
popcircle <- function(x, var){
  # prep data
  x <- x[!is.na(x[[var]]), ]
  x <- x[x[[var]] > 0, ]
  x <- x[order(x[[var]], decreasing = T), ]
  # get layout
  res <- circleProgressiveLayout(x[[var]], sizetype = "area")
  # sf object creation
  . <- sf::st_buffer(sf::st_as_sf(res, coords =c('x', 'y'),
                                  crs = sf::st_crs(x)),
                     dist = res$radius)
  xc <- x
  sf::st_geometry(xc) <- sf::st_geometry(.)
  xc$radius <- .$radius
  # move and resize shapes
  l <- vector("list", nrow(x))
  for(i in 1:nrow(x)){
    circ <- xc[i,]
    shp <- x[i,]
    # carré inscrit dans le cercle
    # large_side = (2 * circ$radius * sqrt(2)) /2
    # diagonal ou grand côté
    large_side = 2 * circ$radius
    pos <- st_bbox(circ)
    bb <- st_bbox(shp)
    xs <- diff(bb[c(1,3)])
    ys <- diff(bb[c(2,4)])
    # grand côté
    # large_bb <- max(xs, ys)
    large_bb <- sqrt(xs^2 + ys^2)
    k <- large_side / large_bb
    pos <- st_bbox(circ)
    cxs <- diff(pos[c(1,3)])
    cys <- diff(pos[c(2,4)])
    xcoo <- pos[1] + circ$radius - (xs * k)/2
    ycoo <- pos[2] + circ$radius - (ys * k)/2
    l[[i]] <- move_and_resize(x = shp, xy = c(xcoo,ycoo), k = k)
  }
  cpop <- do.call(rbind, l)
  # clean
  xc <- xc[, -ncol(xc)]
  return(list(circles = xc, shapes = cpop))
}

move_and_resize <- function(x, xy, k = 1){
  cntrd <- st_centroid(st_combine(x))
  xg <- (st_geometry(x) - cntrd) * k + cntrd[[1]][]
  st_geometry(x) <- xg + xy - st_bbox(xg)[1:2]
  return(x)
}


# library(sf)
# library(cartography)
# library(popcircle)
#
# par(mar = c(0,0,0,0), mfrow = c(2,2))
#
#
# mtq <- st_read(system.file("gpkg/mtq.gpkg", package="popcircle"))
# vv <- popcircle(mtq, "POP")
# plot(st_geometry(vv$circles), col = "darkseagreen", border = "darkseagreen1")
# plot(st_geometry(vv$pop), col = "red", add=T, lwd = 1, border= "red4")
# vv$circles$txt <- paste0(vv$circles$LIBGEO, "\n", round(vv$pop$POP,0), " habs")
# labelLayer(x = vv$circles[1:10,], txt = "txt", halo = T, r = 0.12, overlap = F)
#
#
#
#
# com <- st_read("/home/tim/Documents/prz/NewRep/com46.shp")
# vv <- popcircle(com, "TOT")
# plot(st_geometry(vv$circles), col = "darkseagreen", border = "darkseagreen1")
# plot(st_geometry(vv$pop), col = "red", add=T, lwd = 1, border= "red4")
# vv$circles$txt <- paste0(vv$circles$NOM_COM, "\n", round(vv$pop$TOT,0), " habs")
# labelLayer(x = vv$circles[1:10,], txt = "txt", halo = T, r = 0.15, overlap = F)
#
#
# com31 <- readRDS("/home/tim/Documents/prz/satRday/exercises/data/com_31.rds")
# vv <- popcircle(com31, "P14_POP")
# plot(st_geometry(vv$circles), col = "darkseagreen", border = "darkseagreen1")
# plot(st_geometry(vv$pop), col = "red", add=T, lwd = 1, border= "red4")
# vv$circles$txt <- paste0(vv$circles$INSEE_COM)
# labelLayer(x = vv$circles[1:10,], txt = "txt", halo = T, r = 0.15, overlap = F)
#
#
# data("nuts2006")
# nuts0.spdf@data <- nuts0.df
# n0 <- st_as_sf(nuts0.spdf)
# vv <- popcircle(n0, "pop2008")
# plot(st_geometry(vv$circles), col = "darkseagreen", border = "darkseagreen1")
# plot(st_geometry(vv$pop), col = "red", add=T, lwd = 1, border= "red4")
# vv$circles$txt <- paste0(vv$circles$id, "\n", round(vv$pop$pop2008/1000000,0), " Mio habs")
# labelLayer(x = vv$circles[1:10,], txt = "txt", halo = T, r = 0.15, overlap = F)


