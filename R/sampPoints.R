#' @title Create randomized sampling points
#'  
#' @description Function to create randomized sampling points within spatial polygons, 
#' potentially with additional constraints such as roads
#' 
#' @details This function uses \code{spatstat::rSSI} to generate points. Note that if 
#' \code{spatstat::rSSI} cannot return the desired number of points it will issue a 
#' warning but not an error. If the desired number of points cannot be generated this 
#' is likely because \code{dmin} is too big for the \code{area} and one or both should  
#' be adjusted.
#' 
#' @param n number of points desired
#' @param area the spatial polygons within which points will be made
#' @param dmin minimum distance between points
#' @param name name to be applied to points in the form <name>_01, <name>_02, ...
#' @param seed random seed
#' 
#' @return A \code{SpatialPointsDataFrame} containing randomized sampling points 
#' including a column called \code{name} that is neccesary for output to some formats
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @export 

sampPoints <- function(n, area, dmin, name = 'pnt', seed = 123) {
    # extract all unique polygons
    r <- area@polygons
    o <- lapply(r, function(x) {
        lapply(1:length(x@Polygons), function(i) {
            y <- x@Polygons[[i]]
            SpatialPolygons(list(Polygons(list(y), i)))
        })
    })
    o <- unlist(o)
    
    if(length(o) == 1) { # if only one polygon, proceed with randomization
        w <- as.owin(o[[1]])
        set.seed(seed)
        xy <- as.SpatialPoints.ppp(rSSI(dmin, n, win = w))
    } else { # if multiple, then do a more guided randomization
        # calculate areas of polygons and max numbers of points they can contain
        ae <- lapply(o, function(x) {
            a <- x@polygons[[1]]@Polygons[[1]]@area
            c(a = a, nmax = ceiling(a / ((pi * dmin^2) / 1.25)))
        })
        ae <- do.call(rbind, ae)
        ii <- 1:nrow(ae)
        
        # use that info to randomply select polygons in proportion to their size, 
        # number of times a polygon is selected equals number of potential points
        # in that polygon
        set.seed(seed)
        temp <- sample(ii, n * 50, prob = ae[ii, 1], replace = TRUE)
        temp <- table(temp)
        
        # limit potential number of points to allowable max
        bad <- ae[as.integer(names(temp)), 2] - temp < 0
        temp[bad] <- ae[as.integer(names(temp)), 2][bad]
        
        # generate points within those selected polygons
        pp <- lapply(1:length(temp), function(i) {
            j <- as.integer(names(temp[i])) # the polygon ID
            if(temp[i] == 1) { # only one point to make
                set.seed(seed)
                return(as.data.frame(runifpoint(1, as.owin(o[[j]]))))
            } else { # multiple points to (try) to make
                set.seed(seed)
                return(as.data.frame(rSSI(dmin, temp[i], as.owin(o[[j]]), 
                                          giveup = 50)))
            }
        })
        pp <- do.call(rbind, pp)
        
        # select the desired number of points, excluding any that are too close
        set.seed(seed)
        pp <- pp[order(runif(nrow(pp))), ]
        pdist <- as.matrix(dist(pp)) < dmin
        pp <- pp[which(diag(pdist %*% upper.tri(pdist)) == 0)[1:n], ]
        
        # convert to spatial object
        xy <- SpatialPoints(pp[!is.na(pp[, 1]), ])
    }

    # write out sampling points
    n <- nrow(xy@coords)
    nnchar <- nchar(as.character(n))
    num <- stringr::str_pad(1:n, ifelse(nnchar == 1, 2, nnchar), pad = '0')
    xy <- SpatialPointsDataFrame(xy, 
                                 data = data.frame(name = paste(name, num, sep = '_')))
    proj4string(xy) <- CRS(proj4string(area))
    
    return(xy)
}
