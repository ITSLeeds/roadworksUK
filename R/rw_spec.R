#' View specification documents
#'
#' This function downloads and opens pdf documents containing the specifications
#' associated with data on streetworks provided by Elgin
#'
#' @param spec_type the type of specification document, one of:
#' htdd, enquires, restrictions or ttvdd.
#' @aliases rw_spec_url
#' @export
#' @examples
#' \dontrun{
#' rw_spec()
#' rw_spec("restrictions")
#' }
rw_spec = function(spec_type = c("htdd", "enquires", "restrictions", "ttvdd")) {
  spec_type = match.arg(spec_type)
  u = rw_spec_url(spec_type)
  d = file.path(tempdir(), paste0(spec_type, ".pdf"))
  message("Downloading specification file from:\n", u, "to:\n", d)
  utils::download.file(u, d)
  utils::browseURL(d)
}
#' @rdname rw_spec
#' @examples
#' # rw_spec_url()
rw_spec_url = function(spec_type = "htdd") {
  u_specs = c(
    "https://github.com/ITSLeeds/roadworksUK/releases/download/0.2/20180924_Elgin.Enquires.Dataset.spec.v1.0.pdf",
    "https://github.com/ITSLeeds/roadworksUK/releases/download/0.2/20180924_Elgin.Restrictions.Dataset.spec.v1.0.pdf",
    "https://github.com/ITSLeeds/roadworksUK/releases/download/0.2/20180925_Elgin.HTDD.Specification.v1.0.pdf",
    "https://github.com/ITSLeeds/roadworksUK/releases/download/0.2/20180927_Elgin.TTVDD.spec.v1.0.pdf"
  )
  u_specs[grepl(pattern = spec_type,
                  x = u_specs,
                  ignore.case = TRUE)]
}
