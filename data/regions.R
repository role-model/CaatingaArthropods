regions <- readOGR(system.file('raw_data', 'caatinga_regions.kml', 
                               package = 'CaatingaArthropods'), 'caatinga_regions')
regions@data <- data.frame(region = regions$Name)
regions$region <- gsub('_', '_0', regions$region)
