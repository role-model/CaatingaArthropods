# note: there was a bug, so you'll need to re-install our special package (just do this once)
# you might need to install `devtools` from CRAN
devtools::install_github('role-model/CaatingaArthropods', force = TRUE)

library(CaatingaArthropods)

# load spatial data
loadCaatingaSpatial()
arBoundary <- readOGR('inst/araripe/araripe_shp', 'araripe')

# reproject
arBoundary <- spTransform(arBoundary, CRS(proj4string(roads)))

# clip roads to the park boundary
arRoads <- intersect(roads, arBoundary)


# how far from roads are we willing to hike (in meters)
roadBufferMax <- 4500

# how much of a buffer (in meters) should there be around roads 
# (no points will be made within this distance to a road)
roadBufferMin <- 500

# how much of a buffer (in meters) around the edges of framents should we have
edgeBuffer <- 100

# make sampling are and candidate points
arArea <- sampArea(region = arBoundary, 
                   edgeBuffer = edgeBuffer, 
                   roads = roads, 
                   roadBufferMin = roadBufferMin, 
                   roadBufferMax = roadBufferMax, 
                   exclude = NULL, utmZone = 24)

npnt <- 12
arPoints <- sampPoints(npnt, arArea, dmin = 1000, 
                       name = paste('caa', 'araripe', sep = '_'), 
                       seed = 123)

# reproject to geographical CRS
arPoints <- spTransform(arPoints, CRS(proj4string(roads)))

# write the points out
writeMultiOGR(arPoints, 'inst/araripe/araripe_points', 'araripe_points', 
              driver = c('ESRI Shapefile', 'KML', 'GPX'), overwrite_layer = TRUE)
