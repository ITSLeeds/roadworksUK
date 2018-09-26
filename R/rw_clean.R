#' clean roadworks data
#'
#' @param d roadworks data
#' @export
#' @examples
#' # rw_clean(eton_mess)
rw_clean = function(d) {
  # add timestampt to start time
  d = dplyr::mutate_at(d, dplyr::vars(dplyr::contains("date", ignore.case = TRUE)), lubridate::dmy_hms)
  d
  # traffic management field ????
}
