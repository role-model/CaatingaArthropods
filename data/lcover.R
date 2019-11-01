lcover <- raster(system.file('raw_data', 'landcover_sosma.tif', 
                             package = 'CaatingaArthropods'))
lcoverkey <- data.frame(code = c(14, 20, 30, 40, 50, 60, 110, 120, 130, 
                                 150, 180, 200, 210), 
                        type = c('Cropland', 'Mosaic mostly cropland', 
                                 'Mosaic mostly veg',
                                 'Closed to open evergreen/semideciduous forest', 
                                 'Closed deciduous forest', 'Open deciduous forest', 
                                 'Mosaic mostly forest/shrubland', 
                                 'Mosaic mostly grassland', 'Closed to open shrubland', 
                                 'Sparse vegetation', 
                                 'Grassland or woody veg on regularely flooded soil',
                                 'Bare area', 'Water bodies'), 
                        stringsAsFactors = FALSE)
