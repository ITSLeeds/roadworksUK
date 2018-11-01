#' Create an interactive map of htdd data
#'
#' This function creates a simple static map of roadworks data, for one or more variables.
#'
#' @inheritParams rw_map
#' @param ... Arguments passed to `leaflet()`
#'
#' @export
#' @examples
#' rw_map_interactive(htdd_ashford[1:100, ])
#' rw_map_interactive(htdd_ashford[1:100, ], vars = names(htdd_ashford)[1:3])
rw_map_interactive = function(x, vars = names(x), ...) {
  # should split-out as data object
  if(length(vars) > 10) {
    vars = vars[ vars %in% c("id", "responsible_org_name", "responsible_org_sector", "e__date_created",
             "e__start_date", "e__end_date")]
  }
  x_df = x[vars]
  x_sf =  sf::st_sf(x_df, geometry = sf::st_sfc(x$i__location_point, crs = 27700))
  x_sf = sf::st_transform(x_sf, 4326)
  ic_text = rep("X", nrow(x))
  if("responsible_org_sector" %in% vars) {
    ic_text[x_df$responsible_org_sector == "Highway Authority"] = emojifont::emoji("construction")
    ic_text[x_df$responsible_org_sector == "Water"] = emojifont::emoji("potable_water")
    ic_text[x_df$responsible_org_sector == "Electricity"] = emojifont::emoji("electric_plug")
    ic_text[x_df$responsible_org_sector == "Rail"] = emojifont::emoji("bullettrain_side")
    ic_text[x_df$responsible_org_sector == "Gas"] = emojifont::emoji("fire")
  }

  ic = leaflet::makeAwesomeIcon(text = ic_text)
  p = paste0(vars[1], ": ", x_df[, 1])
  if(length(vars) > 1) {
    for(i in 2:length(vars)) {
      pn = paste0(vars[i], ": ", x_df[, i])
      p = paste0(p, "<br>", pn)
    }
  }
  leaflet::leaflet(data = x_sf) %>%
    leaflet::addTiles() %>%
    leaflet::addAwesomeMarkers(popup = p, icon = ic)
    # leaflet::addPopups(popup = x_sf[vars])
}
