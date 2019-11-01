#' @title Wrapper around \code{rgdal::writeOGR} to succinctly write multiple files
#'  
#' @description For every driver name in \code{driver}, thus function makes an 
#' appropriate call to \code{rgdal::writeOGR}
#' 
#' @details See \code{rgdal::writeOGR}
#' 
#' @param obj the object to write
#' @param dsn the path to the file to be written
#' @param layer the layer name
#' @param driver a character vector giving the name(s) of drivers to use
#' @param ... other arguments passed to \code{rgdal::writeOGR}
#' 
#' @return See \code{rgdal::writeOGR}
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @export 

writeMultiOGR <- function(obj, dsn, layer, driver, ...) {
    for(d in driver) {
        thisDSN <- if(d == 'KML') {
            paste(dsn, 'kml', sep = '.')
        } else if(d == 'GPX') {
            paste(dsn, 'gpx', sep = '.')
        } else {
            dsn
        }
        
        writeOGR(obj, thisDSN, layer, driver = d, ...)
    }
}
