#' EtON roadworks data (raw HTDD logs from Elgin)
#'
#' This dataset represents eton data provided as a csv file by Elgin.
#' Specifically it is a month's (June 2018) of data with almost 1000 records
#' from Ashford, Kent.
#' kent10 is a tiny subset of this dataset with 10 records.
#' `ashford_bng` is in the British National Grid CRS.
#'
#' @docType data
#' @keywords datasets
#' @name htdd_ashford
#' @aliases kent10 ashford ashford_bng
#' @format A data frame
#'
#' @examples \dontrun{
#' d = "HDDT v2/"
#' list.files(d)
#' f = "elgin.htdd.export.20180601-20180630.csv.gzip"
#' file_path = file.path(d, f)
#' file.exists(file_path) # check the file is there
#' eton_all = rw_import_elgin_htdd(file_path)
#' ashford = osmdata::getbb("ashford uk", format_out = "sf_polygon")
#' library(sf)
#' ashford_bng = st_transform(ashford, 27700)
#' plot(ashford_bng)
#' eton_all_sf = st_sf(eton_all$e__location_bng)
#' sel_ashford = as.logical(st_intersects(eton_all_sf, ashford_bng, sparse = TRUE))
#' sel_ashford[is.na(sel_ashford)] = FALSE
#' summary(sel_ashford)
#' htdd_ashford = eton_all[sel_ashford, ]
#' nrow(htdd_ashford)
#' sel_non_standard = grepl("[[:cntrl:]]",
#'  stringi::stri_enc_toascii(htdd_ashford$e__location_description))
#' summary(sel_non_standard)
#'
#' htdd_ashford$description =
#'   stringi::stri_trans_general(htdd_ashford$description, "latin-ascii")
#' htdd_ashford$e__location_description =
#'   stringi::stri_trans_general(htdd_ashford$e__location_description, "latin-ascii")
#' htdd_ashford$i__permit_condition =
#'   stringi::stri_trans_general(htdd_ashford$i__permit_condition, "latin-ascii")
#' htdd_ashford$i__location_description =
#'   stringi::stri_trans_general(htdd_ashford$i__location_description, "latin-ascii")
#' }
#' names(htdd_ashford)
#' sapply(htdd_ashford, class)
#' plot(htdd_ashford$e__location_bng)
#' plot(htdd_ashford$i__start_date)
NULL

#' Highway authorities
#'
#' These are the highway authorities in the UK.
#' `highway_authorities_mod` is a modified version for plotting.
#'
#' @docType data
#' @keywords datasets
#' @name highway_authorities
#' @aliases highway_authorities_mod
#' @format An sf object
#'
#' @examples \dontrun{
#' highway_authorities = sf::read_sf("data/boundaries/ha.gpkg")
#' highway_authorities = rmapshaper::ms_simplify(highway_authorities)
#' # highway_authorities = sf::st_simplify(highway_authorities, 0.001)
#' pryr::object_size(highway_authorities)
#' }
#' sf:::plot.sf(highway_authorities)
#' sf:::plot.sf(highway_authorities_mod)
NULL

#' msoa boundary data for ashford
#'
#' A sample of UK administrative boundaries for educational purposes
#' for Ashford, UK.
#'
#' @docType data
#' @keywords datasets
#' @name msoa_ashford
#' @format An sf object
#'
#' @examples \dontrun{
#' msoa_uk = sf::read_sf("data/boundaries/msoa.gpkg")
#' pryr::object_size(msoa_uk) # 66 MB
#' msoa_uk_cent = sf::st_centroid(msoa_uk)
#' msoa_ashford_cent = msoa_uk_cent[ashford_bng, ]
#' msoa_ashford = msoa_uk[msoa_uk$id %in% msoa_ashford$id, ]
#' }
#' plot(msoa_ashford$geom)
#' plot(htdd_ashford$i__location_point, add = TRUE)
NULL

#' Road statistics for HAs
#'
#' Summary statistics on roads in highway authorities.
#'
#' @docType data
#' @keywords datasets
#' @name road_stats
#' @format An sf object
#'
#' @examples \dontrun{
#' road_stats = readRDS("data/HA_RoadStats.Rds")
#' usethis::use_data(road_stats)
#' }
#' summary(road_stats$name %in% highway_authorities$name)
#' road_stats
NULL

#' URLs pointing to roadworks data spec from Elgin
#'
#' @docType data
#' @keywords datasets
#' @name spec_urls
#' @format Character vector
#' @examples \dontrun{
#' f = list.files(pattern = "pdf")
#' piggyback::pb_upload(f)
#' u = piggyback::pb_download_url()
#' spec_urls = u[grepl(pattern = "Elgin", x = u)]
#' road_stats = readRDS("data/HA_RoadStats.Rds")
#' usethis::use_data(road_stats)
#' }
#' spec_urls
#' spec_urls[grepl("HTDD", spec_urls)]
NULL
