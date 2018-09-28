#' Match Points to Regions
#'
#' @param points simple features column of points
#' @param regions simple features data frame of polygons
#' @param ncores number of core to run (default = 1)
#'
#' @examples \dontrun{
#' zip_file = "data/01.zip"
#' d = rw_import_scot(zip_file)
#' ncol(d) # 74 columns
#' }
rw_points_to_region = function(points, regions, ncores = 1){

  if(is.na(st_crs(points))){
    message("No CRS for points, assuming EPSG:27700 British National Grid")
    sf::st_crs(points) = 27700
  }

  if(ncores == 1){
    intersects = st_intersects(points,regions)
  }else{
    # Split into ncore groups
    ngroup = ceiling(length(points)/ncores)
    split_results = split(points, ceiling(seq_along(points)/ngroup))

    # Set Up Cluser
    CL <- parallel::makeCluster(ncores) #make clusert and set number of core
    parallel::clusterExport(cl = CL, varlist=c("regions"), envir = environment())
    parallel::clusterEvalQ(cl = CL, {library(sf)})
    intersects = parallel::parLapply(cl = CL,split_results,st_intersects, y = regions)
    parallel::stopCluster(CL)
    intersects = unlist(intersects, recursive = F)
  }


  lens = lengths(intersects)
  intersects = lapply(1:length(intersects),function(x){ifelse(lens[x]<=1,intersects[[x]],intersects[[x]][1])})
  names(intersects) = NULL
  intersects = unlist(intersects)
  ids = regions$id[intersects]

  return(ids)

}


