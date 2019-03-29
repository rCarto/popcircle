# popcircle

![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)
[![Build Status](https://travis-ci.org/rCarto/popcircle.svg?branch=master)](https://travis-ci.org/rCarto/popcircle)
[![codecov](https://codecov.io/gh/rCarto/popcircle/branch/master/graph/badge.svg)](https://codecov.io/gh/rCarto/popcircle)

![](https://raw.githubusercontent.com/rCarto/popcircle/master/img/front.png)

This one-function package computes polygons with areas scaled to a variable and displays them using a compact layout (big values in the center, small values at the periphery).

## Example

``` r
library(sf)
library(popcircle)
mtq <- st_read(system.file("gpkg/mtq.gpkg", package="popcircle"))
res <- popcircle(x = mtq, var = "POP")
circles <- res$circles
shapes <- res$shapes
par(mar = c(0,0,0,0))
plot(st_geometry(circles), col = "black", border = "black")
plot(st_geometry(shapes), col = "red", add = TRUE, lwd = 1, border = "red4")
if(require(cartography)){
  labelLayer(x = circles[1:10,], txt = "LIBGEO", halo = TRUE, overlap = FALSE, 
             col ="white", bg = "black", r = .15)
}
```
![](https://raw.githubusercontent.com/rCarto/popcircle/master/img/ex.png)
