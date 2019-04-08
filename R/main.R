#' @title Proportional Circles and Shapes
#' @name popcircle
#' @description Get proportional circles and with polygons indide using a compact layout.
#' @param x an sf POLYGON or MULTIPOLYGON object
#' @param var name of the numeric field in x to get proportionalities.
#' @return A list of length 2 of circles and shapes sf objects.
#' @details Polygons are not proportional, they are rescaled to fit the circles.
#' @export
#' @importFrom packcircles circleProgressiveLayout
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
  st_crs(cpop) <- st_crs(xc)
  return(list(circles = xc, shapes = cpop))
}

move_and_resize <- function(x, xy, k = 1){
  cntrd <- st_centroid(st_combine(x))
  xg <- (st_geometry(x) - cntrd) * k + cntrd[[1]][]
  st_geometry(x) <- xg + xy - st_bbox(xg)[1:2]
  return(x)
}
