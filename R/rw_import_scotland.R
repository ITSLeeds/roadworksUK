#' Import Scottish road works data
#'
#' This function imports data that has already been downloaded from
#' https://downloads.srwr.scot/export
#'
#' @examples \dontrun{
#' zip_file = "data/01.zip"
#' d = rw_import_scot(zip_file)
#' ncol(d) # 74 columns
#' }
rw_import_scot = function(zip_file, dest_dir = tempdir()) {
  spec = rw_spec_scottish()
  unzip(zip_file, exdir = dest_dir)
  csv_file = list.files(dest_dir, pattern = "*.csv", full.names = TRUE)
  # d = read.csv(csv_file, header = FALSE)
  d = readr::read_csv(csv_file, col_names = paste0("x", 1:74),
                      col_types = rw_spec_scottish())
  names(d) = rw_spec_scottish_names()
  # d = readr::read_csv(csv_file, col_types = rw_spec_scottish())
  d
}

#' Scottish road works spec
#'
#' From https://downloads.srwr.scot/export
rw_spec_scottish = function() {
  readr::cols(
    x1 = "i",
    x2 = "c",
    x3 = "i",
    x4 = readr::col_datetime(),
    x5 = "d"
  )
}
rw_spec_scottish_names = function() {
  n = paste0("x", 1:74)
  n[1:5] = c(
    "version",
    "record_type",
    "activity_id",
    "created_date_time",
    "last_updated_date_time"
  )
  n[13] = "geometry"
  n
}

