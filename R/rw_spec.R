#' View specification documents associated with data provided by Elgin
#'
#' @param spec_type the type of specification document, one of:
#' htdd, enquires, restrictions or ttvdd.
#'
#' @export
#' @example
#' \dontrun{
#' rw_spec()
#' rw_spec(spec_urls[1])
#' }
#'
rw_spec = function(spec_type = c("htdd", "enquires", "restrictions", "ttvdd")) {
  u = grepl(pattern = spec_type, spec_urls)
  d = file.path(tempdir(), paste0(spec_type, ".pdf"))
  message("Downloading specification file from:\n", u, "to:\n", d)
  download.file(u, d)
  browseURL(d)
}
