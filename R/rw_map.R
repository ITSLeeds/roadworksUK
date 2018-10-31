#' Create a static map of htdd data
#'
#' This function creates a simple static map of roadworks data, for one or more variables.
#'
#' @param x A dataset containing htdd data object created with [rw_import_elgin_htdd()]
#' @param vars A text string of variables to be show, one facet for each
#'
#' @export
#' @examples
#' rw_map(htdd_ashford)
rw_map = function(x, vars = c("responsible_org_sector", "i__start_date")) {
  x_sf =  sf::st_sf(x$i__location_point, x)
  graphics::plot(x_sf[vars])
}
