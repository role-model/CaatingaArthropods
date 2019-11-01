#' @title Load the spatial data you'll need
#'  
#' @description A helper function to load raw spatial data
#' 
#' @details Runs \code{source} on a system file that contains code to load other system 
#' files containing needed spatial data
#' 
#' @param message a nice thing to say to yourself
#' 
#' @return Creats the following objects
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
