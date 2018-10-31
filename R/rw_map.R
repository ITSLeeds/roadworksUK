#' Create a static map of htdd data
#'
#' This function creates a simple static map of roadworks data, for one or more variables.
#'
#' @param x A dataset containing htdd data object created with [rw_import_elgin_htdd()]
#' @param vars A text string of variables to be show, one facet for each
#' @param ... Arguments passed to `plot()`
#'
#' @export
#' @examples
#' rw_map(htdd_ashford[1:100, ])
rw_map = function(x, vars = c("responsible_org_sector"), key.width = 6, ...) {
  x_sf =  sf::st_sf(x, sf_column_name = "i__location_point")
  graphics::plot(x_sf[vars], key.width = graphics::lcm(key.width), ...)
}
