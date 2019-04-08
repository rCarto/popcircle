# popcircle

![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)
[![Build Status](https://travis-ci.org/rCarto/popcircle.svg?branch=master)](https://travis-ci.org/rCarto/popcircle)
[![codecov](https://codecov.io/gh/rCarto/popcircle/branch/master/graph/badge.svg)](https://codecov.io/gh/rCarto/popcircle)

![](https://raw.githubusercontent.com/rCarto/popcircle/master/img/pop.png)

This one-function package computes circles with areas scaled to a variable and displays them using a compact layout (higher values in the center, lower values at the periphery). Original polygons are scaled to fit inside these circles (size are roughly proportional, not strictly). 

![](https://raw.githubusercontent.com/rCarto/popcircle/master/img/co2.png)

## Example

See [this gist](https://gist.github.com/rCarto/34c7599d7d89a379db02c663c2e333ee) for the code used to produce figures on countries population and CO2 emissions.  


### Interactive Visualisation

[Here](https://rcarto.github.io/popcircle/index.html) is an example of interactive visualisation using `leaflet`. 

![](https://raw.githubusercontent.com/rCarto/popcircle/master/img/inter.gif)


### Typical example

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
