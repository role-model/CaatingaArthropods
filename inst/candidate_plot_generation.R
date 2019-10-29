library(CaatingaArthropods)
options(stringsAsFactors = FALSE)

# read in data

lcover <- raster('data/landcover_sosma.tif')
lcoverkey <- data.frame(code = c(14, 20, 30, 40, 50, 60, 110, 120, 130, 
                                 150, 180, 200, 210), 
                        type = c('Cropland', 'Mosaic mostly cropland', 'Mosaic mostly veg',
                                 'Closed to open evergreen/semideciduous forest', 
                                 'Closed deciduous forest', 'Open deciduous forest', 
                                 'Mosaic mostly forest/shrubland', 
                                 'Mosaic mostly grassland', 'Closed to open shrubland', 
                                 'Sparse vegetation', 
                                 'Grassland or woody veg on regularely flooded soil',
                                 'Bare area', 'Water bodies'), 
                        stringsAsFactors = FALSE)

roads <- readOGR('data/BRA_rds', 'BRA_roads')
forest <- readOGR('data/sosma_fragments', 'sosma')
forest <- forest[forest$legenda == 'Mata', ]
regions <- readOGR('data/caatinga_regions.kml', 'caatinga_regions')

# combine forest with region
forest <- intersect(forest, regions)
forest@data <- forest@data[, 1:3]
names(forest@data) <- c('UF', 'type', 'region')
forest$region <- gsub('_', '_0', forest$region)

# find cover types that we don't want
good <- c(40, 50, 60)
bad <- rasterToPolygons(lcover, function(x) !(x %in% good), dissolve = TRUE)

# made candidate points
candArea <- sampArea(region = forest[forest$region == 'region_01', ], edgeBuffer = 100, 
                     roads = roads, roadBufferMin = 500, roadBufferMax = 2500, 
                     exclude = bad, 
                     utmZone = 24)
plot(candArea)
candPnts <- sampPoints(12, candArea, 1000, name = 'caa01', seed = 123)
points(candPnts)
