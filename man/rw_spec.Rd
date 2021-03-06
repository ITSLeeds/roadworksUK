% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rw_spec.R
\name{rw_spec}
\alias{rw_spec}
\alias{rw_spec_url}
\title{View specification documents}
\usage{
rw_spec(spec_type = c("htdd", "enquires", "restrictions", "ttvdd"))

rw_spec_url(spec_type = "htdd")
}
\arguments{
\item{spec_type}{the type of specification document, one of:
htdd, enquires, restrictions or ttvdd.}
}
\description{
This function downloads and opens pdf documents containing the specifications
associated with data on streetworks provided by Elgin
}
\examples{
\dontrun{
rw_spec()
rw_spec("restrictions")
}
# rw_spec_url()
}
