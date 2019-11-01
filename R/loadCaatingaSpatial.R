#' @title Load the spatial data you'll need
#'  
#' @description A helper function to load raw spatial data
#' 
#' @details Runs \code{source} on a system file that contains code to load other system 
#' files containing needed spatial data
#' 
#' @param message a nice thing to say to yourself
#' 
#' @return Creats the following objects:
#' \describe{
#'   \item{\code{forest}}{SOSMA fragments as a \code{SpatialPolygonsDataFrame}}
#'   \item{\code{lcover}}{SOSMA landcover classes as a \code{raster}}
#'   \item{\code{lcoverke}}{key to SOSMA landcover as a \code{data.frame}}
#'   \item{\code{regions}}{a \code{SpatialPolygonsDataFrame} that delineates the different regions}
#'   \item{\code{roads}}{a \code{SpatialLinesDataFrame} of the roads}
#' }
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @export 

loadCaatingaSpatial <- function(message = 'Here ya go...') {
    cat(message, '\n')
    options(warn = -1)
    
    quiet <- function(x) { 
        sink(tempfile()) 
        on.exit(sink()) 
        invisible(force(x)) 
    } 
    
    quiet(source(system.file('raw_data', 'read-in_raw.R', 
                             package = 'CaatingaArthropods')))
    options(warn = 0)
}
