library(rnaturalearth)
library(sf)
library(wbstats)
library(popcircle)
library(cartography)

# Get countries
ctry <- ne_countries(scale = 50, returnclass = "sf")
ctry <- st_transform(ctry, 54030)

# Only keep the largest polygons of multipart polygons for a few countries
# (e.g. display only continental US)
frag_ctry <- c("US", "RU", "FR", "IN", "ES", "NL", "CL", "NZ", "ZA")
largest_ring = function(x) {
  x$ids <- 1:nrow(x)
  pols = st_cast(x, "POLYGON", warn = FALSE)
  spl = split(x = pols, f = pols$ids)
  do.call(rbind, (lapply(spl, function(y) y[which.max(st_area(y)),])))
}
st_geometry(ctry[ctry$iso_a2 %in% frag_ctry,]) <-
  st_geometry(largest_ring(ctry[ctry$iso_a2 %in% frag_ctry,]))


# Get and merge data
data_co2 <- wb(indicator = "EN.ATM.CO2E.KT", startdate = 2014, enddate = 2014)
ctry_co2 <- merge(ctry[,"iso_a2"], data_co2, by.x = "iso_a2", by.y = "iso2c" )
data_pop <- wb(indicator = "SP.POP.TOTL", startdate = 2017, enddate = 2017)
ctry_pop <- merge(ctry[,"iso_a2"], data_pop, by.x = "iso_a2", by.y = "iso2c" )

# Computes circles and polygons
res_pop <- popcircle(x = ctry_pop, var = "value")
circles_pop <- res_pop$circles
shapes_pop <- res_pop$shapes
res_co2 <- popcircle(x = ctry_co2, var = "value")
circles_co2 <- res_co2$circles
shapes_co2 <- res_co2$shapes

# Create the figure
png("img/pop.png", width = 800, height = 750, res = 100)
par(mar = c(0,0,0,0))
## POPULATION
# display circles and polygons
plot(st_geometry(circles_pop), bg = "#e6ebe0",col = "#9bc1bc", border = "white")
plot(st_geometry(shapes_pop), col = "#ed6a5a95", border = "#ed6a5a",
     add = TRUE, lwd = .3)
# labels
circles_pop$lab <- paste0(circles_pop$country, '\n',
                      round(circles_pop$value/1000000))
labelLayer(x = circles_pop[1:36,], txt = "lab", halo = TRUE, overlap = FALSE,
           pos = 3, cex = .7, col = "#5d576b", r=.15)
# title
bb <- st_bbox(circles_pop)
text(x = bb[1], bb[4], labels = "Population", adj=c(0,1),
     col = "grey50", cex = 2)
text(x = bb[3], bb[4], labels = "Million Inhabitants", adj=c(1,1),
     col = "grey50", cex = 1.2, font = 3)
mtext(text = "T. Giraud, 2019 - World Development Indicators, 2017 ",
      side = 1, line = -1, adj = 1, cex = .8, font = 3)
dev.off()


## CO2
# Create the figure
png("img/co2.png", width = 800, height = 750, res = 100)
par(mar = c(0,0,0,0))
# display circles and polygons
plot(st_geometry(circles_co2),bg = "#a2a79e", col = "#757083", border = "white")
plot(st_geometry(shapes_co2), col = "#88292f95", border = "#88292f",
     add = TRUE, lwd = .3)
# labels
circles_co2$lab <- paste0(circles_co2$country, '\n',
                          round(circles_co2$value/1000))
labelLayer(x = circles_co2[1:36,], txt = "lab", halo = TRUE, overlap = FALSE,
           pos = 3, cex = .7, col = "#2e1e0f", r=.15, show.lines = FALSE)
# title
bb <- st_bbox(circles_co2)
text(bb[1], bb[4], labels = "CO2 Emissions", adj=c(0,1),
     col = "white", cex = 2)
text(x = bb[3], bb[4], labels = "Million Tons", adj=c(1,1),
     col = "white", cex = 1.2, font = 3)
# sources
mtext(text = "T. Giraud, 2019 - World Development Indicators, 2014 ",
      side = 1, line = -1, adj = 1, cex = .8, font = 3)
dev.off()
