## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- load_package-------------------------------------------------------
library(CaatingaArthropods)

## ------------------------------------------------------------------------
options(stringsAsFactors = FALSE)

## ------------------------------------------------------------------------
loadCaatingaSpatial()

## ------------------------------------------------------------------------
# clip roads to region
roads <- intersect(roads, regions)
names(roads)[names(roads) == 'Name'] <- 'region'

# combine forest with region
forest <- intersect(forest, regions)

# find cover types that we don't want
good <- c(40, 50, 60)
bad <- rasterToPolygons(lcover, function(x) !(x %in% good), dissolve = TRUE)

## ------------------------------------------------------------------------
knitr::kable(lcoverkey[lcoverkey$code %in% good, ])

## ------------------------------------------------------------------------
knitr::kable(lcoverkey[!(lcoverkey$code %in% good), ])

## ------------------------------------------------------------------------
# how far from roads are we willing to hike (in meters)
roadBufferMax <- 4500

# how much of a buffer (in meters) should there be around roads 
# (no points will be made within this distance to a road)
roadBufferMin <- 500

# how much of a buffer (in meters) around the edges of framents should we have
edgeBuffer <- 100

## ------------------------------------------------------------------------
# get list of region names
rr <- unique(forest$region)

# list the desired number of candidate points for each region
# NOTE: we're putting 24 in region 1, which is the long north-south ridge
# in the western part of the Caatinga; in all other regions we put 12 points
npnt <- c(24, rep(12, 6))
names(npnt) <- rr

# now we'll look over regions and make points
candArea <- candPnts <- vector('list', length(rr))
names(candArea) <- names(candPnts) <- rr

for(i in rr) {
    candArea[[i]] <- sampArea(region = forest[forest$region == i, ], 
                                  edgeBuffer = edgeBuffer, 
                              roads = roads[roads$region == i, ], 
                              roadBufferMin = roadBufferMin, 
                              roadBufferMax = roadBufferMax, 
                              exclude = bad, utmZone = 24)
    candPnts[[i]] <- sampPoints(npnt[i], candArea[[i]], 1000, 
                                name = paste0('caa', gsub('region_', '', i)), 
                                seed = 123)
    
    # make candArea[[i]] into a SpatialPolygonsDataFrame
    np <- length(candArea[[i]]@polygons)
    candArea[[i]] <- SpatialPolygonsDataFrame(candArea[[i]], 
                                              data.frame(region = rep(i, np)), 
                                              match.ID = FALSE)
    
}

# combine and re-project into original CRS
candArea <- do.call(rbind, candArea)
candArea <- spTransform(candArea, CRS(proj4string(regions)))
candPnts <- do.call(rbind, candPnts)
candPnts <- spTransform(candPnts, CRS(proj4string(regions)))

## ---- eval = FALSE-------------------------------------------------------
#  writeMultiOGR(candPnts, 'inst/cand_points', 'cand_points',
#                driver = c('ESRI Shapefile', 'KML', 'GPX'), overwrite_layer = TRUE)
#  writeMultiOGR(candArea, 'inst/samp_areas', 'samp_areas',
#                driver = c('ESRI Shapefile', 'KML'), overwrite_layer = TRUE)
#  writeMultiOGR(bad, 'inst/bad_areas', 'bad_areas',
#                driver = c('ESRI Shapefile', 'KML'), overwrite_layer = TRUE)
#  writeOGR(forest, 'inst/forest.kml', 'forest', driver = 'KML', overwrite_layer = TRUE)
#  writeOGR(roads, 'inst/roads.kml', 'roads', driver = 'KML', overwrite_layer = TRUE)

