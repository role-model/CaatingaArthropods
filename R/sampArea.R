#' @title Create a sampling area
#'  
#' @description Function to create an area for generating sampling points within
#' 
#' @details Regardless of the CRS of the input polygons, thus function internally converts
#' to and returns a polygon in a UTM projection, which is important for distance
#' calculations.
#' 
#' @param region the larger area to consider (a \code{SpatialPolygonsDataFrame})
#' @param edgeBuffer an optional buffer to exclude edge effects
#' @param roads a \code{SpatialLinesDataFrame} of access roads
#' @param roadBufferMin the buffer to exclude around roads (in meters)
#' @param roadBufferMax the max distance from roads within which points will be created 
#' (in meters)
#' @param exclude an optional additional area to exclude as a \code{Spatial}* object
#' @param utmZone the UTM zone to use for reprojection to UTM
#' 
#' @return A \code{SpatialPointsDataFrame} containing randomized sampling points
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @export 

sampArea <- function(region, edgeBuffer = NULL, roads, 
                     roadBufferMin = 100, roadBufferMax = 2100,
                     exclude = NULL, utmZone = 13) {
    # crs in units of meters
    crs <- CRS(sprintf('+proj=utm +zone=%s +ellps=WGS84 +datum=WGS84 +units=m +no_defs', 
                       utmZone))
    
    # if the two objects are already in the same projection, clip roads so we 
    # don't waste computation
    if(proj4string(region) == proj4string(roads)) {
        roads <- raster::intersect(roads, region)
        roadClip <- TRUE
    } else {
        roadClip <- FALSE
    }

    region <- spTransform(region, crs)
    if(!is.null(edgeBuffer)) region <- gBuffer(region, width = -edgeBuffer)

    roads <- spTransform(roads, crs)
    
    if(!roadClip) roads <- raster::intersect(roads, region)
    
    # build sampling area
    sampHere <- gBuffer(roads, width = roadBufferMax)
    sampHere <- gIntersection(sampHere, region, byid = TRUE, drop_lower_td = TRUE)
    sampHere <- gDifference(sampHere, gBuffer(roads, width = roadBufferMin))
    
    if(!is.null(exclude)) {
        exclude <- spTransform(exclude, crs)
        exclude <- raster::intersect(exclude, region)
        sampHere <- gDifference(sampHere, exclude)
    }
    
    return(sampHere)
}
