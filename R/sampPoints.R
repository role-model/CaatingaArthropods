#' @title Create randomized sampling points
#'  
#' @description Function to create randomized sampling points within spatial polygons, 
#' potentially with additional constraints such as roads
#' 
#' @details This function uses \code{spatstat::rSSI} to generate points. Note that if 
#' \code{spatstat::rSSI} cannot return the desired number of points it will issue a 
#' warning but not an error. If the desired number of points cannot be generated this 
#' is likely because \code{dmin} is too big for the \code{area} and one or both should be 
#' adjusted.
#' 
#' @param n number of points desired
#' @param area the spatial polygons within which points will be made
#' @param dmin minimum distance between points
#' @param name name to be applied to points in the form <name>_01, <name>_02, ...
#' @param seed random seed
#' 
#' @return A \code{SpatialPointsDataFrame} containing randomized sampling points including
#' a column called \code{name} that is neccesary for output to some formats
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @export 

sampPoints <- function(n, area, dmin, name = 'pnt', seed = 123) {
    # browser()
    r <- area@polygons
    
    # if(length(r) == 1 & length(r[[1]]@Polygons) > 1) {
    #     r <- r[[1]]@Polygons
    #     r <- lapply(1:length(r), function(i) {
    #         Polygons(list(r[[i]]), as.character(i))
    #     })
    # }
    
    r <- lapply(r, function(x) SpatialPolygons(list(x)))
    w <- lapply(r, function(x) {
        o <- try(as.owin(x))
        # if(class(o) == 'try-error') browser()
        o
    })
    te <- tess(tiles = w)
    
    set.seed(seed)
    xy <- rSSI(dmin, n, win = te)
    
    nnchar <- nchar(as.character(n))
    num <- stringr::str_pad(1:n, ifelse(nnchar == 1, 2, nnchar), pad = '0')
    xy <- SpatialPointsDataFrame(as.SpatialPoints.ppp(xy), 
                                 data = data.frame(name = paste(name, num, sep = '_')), 
                                 proj4string = CRS(proj4string(area)))
    
    return(xy)
}
