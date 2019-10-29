#' @title Create randomized sampling points
#'  
#' @description Function to create randomized sampling points within spatial polygons, potentially with additional constraints such as roads
#' 
#' @details foo
#' 
#' @param x vector of integers representing a sample of species abundances
#' @param model character naming model to be fit (can only be length one)
#' @param par vector of model parameters
#' @param keepData logical, should the data be stored with the fitted \code{sad} object
#' 
#' @return A \cod{SpatialPointsDataFrame} containing randomized sampling points
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @export 

sampPoints <- function(n, area, dmin, seed = 123) {
    set.seed(seed)
    xy <- SpatialPoints(cbind(x = runif(n * 100, bbox(area)[1, 1], bbox(area)[1, 2]), 
                              y = runif(n * 100, bbox(area)[2, 1], bbox(area)[2, 2])), 
                        proj4string = CRS(proj4string(area)))
    
    xy <- xy[!is.na(over(xy, area)[, 1]), ]
    
    set.seed(seed)
    xy <- xy[sample(nrow(xy@coords), n), ]
    
    d <- spDists(xy)
    g <- cutree(hclust(as.dist(d)), h = dmin / 1)
    
    xy <- SpatialPointsDataFrame(xy, data = data.frame(name = 1:n, group = g), 
                                 proj4string = CRS(proj4string(area)))
    
    return(xy)
}


candPoints <- sampPoints(12, x, 200, seed = 3)

plot(x)
points(candPoints)

candPoints@data <- candPoints@data[, 1, drop = FALSE]
candPoints$name <- paste0('rcrTemp_', 
                          sapply(candPoints$name, function(i) paste(rep(0, 2 - nchar(i)), 
                                                                    collapse = '')), 
                          candPoints$name)

candPoints <- spTransform(candPoints, origCRS)

writeOGR(candPoints, 'cri_rcr_candidate.GPX', 'rcr_candidate', driver = 'GPX')
writeOGR(candPoints, 'cri_rcr_candidate.kml', 'rcr_candidate', driver = 'KML')
