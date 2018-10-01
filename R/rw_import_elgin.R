#' Import Elgin HDDT road works data
#'
#' This function imports data that has already been downloaded from
#' http://downloads.roadworks.org/
#'
#' @param file_path where the input data is stored, e.g. C:/eton-file.csv
#' @export
#' @examples \dontrun{
#' # f = system.file()
#' d = "N:/Earth&Environment/Research/ITS/Research-1/CyIPT/roadworksUK/data/HDDT v2/"
#' list.files(d)
#' f = "elgin.htdd.export.20180601-20180630.csv.gzip"
#' file_path = file.path(d, f)
#' file.exists(file_path) # check the file is there
#' d_raw = read.csv(file_path, stringsAsFactors = FALSE)
#' names(d_raw)
#' summary(as.factor(d_raw$publisher_name))
#' d_raw_kent = d_raw[d_raw$publisher_name == "Kent County Council", ]
#' kent10 = d_raw_kent[sample(nrow(d_raw_kent), 10), ]
#' write.csv(d_kent10, "inst/extdata/kent10.csv")
#' R.utils::gzip("inst/extdata/kent10.csv", remove = FALSE)
#' }
#' file_path = system.file("extdata", "kent10.csv.gz", package = "roadworksUK")
#' file.exists(file_path)
#' kent10 = rw_import_elgin_htdd(file_path = file_path)
#' ncol(kent10) # 90 columns
#' # View(kent10) # view the data
#' kent10$i__location_point[1]
#' kent10$i__location_bng[3]
rw_import_elgin_htdd = function(file_path) {
  data <- utils::read.csv(file_path, stringsAsFactors = FALSE)

  # data$entity_type_name = as.factor(data$entity_type_name)
  # data$publisher_name = as.factor(data$publisher_name)
  # data$responsible_org_name = as.factor(data$responsible_org_name)
  # data$responsible_org_sector = as.factor(data$responsible_org_sector)
  # data$entity_category = as.factor(data$entity_category)
  # data$entity_category_description = as.factor(data$entity_category_description)
  # data$e__works_category = as.factor(data$e__works_category)
  # data$e__impact_score = as.factor(data$e__impact_score)
  # data$e__traffman_code = as.factor(data$e__traffman_code)
  # data$e__works_state = as.factor(data$e__works_state)
  # data$e__permit_status = as.factor(data$e__permit_status)
  # data$e__status = as.factor(data$e__status)
  # data$e__works_activity_code = as.factor(data$e__works_activity_code)
  # data$e__start_date_estimated = as.factor(data$e__start_date_estimated)
  # data$e__end_date_estimated = as.factor(data$e__end_date_estimated)
  # data$e__la_name = as.factor(data$e__la_name)
  # data$i__item_type = as.factor(data$i__item_type)
  # data$i__traffman_code = as.factor(data$i__traffman_code)
  # data$i__impact_score = as.factor(data$i__impact_score)
  # data$i__works_type = as.factor(data$i__works_type)
  # data$i__works_status = as.factor(data$i__works_status)
  # data$i__works_state = as.factor(data$i__works_state)
  # data$i__works_state_derived = as.factor(data$i__works_state_derived)
  # data$i__la_name = as.factor(data$i__la_name)

  data$e__date_created = lubridate::ymd_hms(data$e__date_created)
  data$e__date_updated = lubridate::ymd_hms(data$e__date_updated)
  data$e__start_date = lubridate::ymd_hms(data$e__start_date)
  data$e__end_date = lubridate::ymd_hms(data$e__end_date)
  data$i__date_created = lubridate::ymd_hms(data$i__date_created)
  data$i__date_updated = lubridate::ymd_hms(data$i__date_updated)
  data$i__start_date = lubridate::ymd_hms(data$i__start_date)
  data$i__end_date = lubridate::ymd_hms(data$i__end_date)
  data$e__archive_date = lubridate::ymd_hms(data$e__archive_date)
  data$i__archive_date = lubridate::ymd_hms(data$i__archive_date)
  data$filter_ds = lubridate::ymd_hms(data$filter_ds)

  # Clean location Data
  data = rw_clean_points(data)

  return(data)
}



#' Import Elgin Restrictions road works data
#'
#' This function imports data that has already been downloaded from
#' http://downloads.roadworks.org/
#'
#' @param file_path path to csv file or compressed file
#'
#' @details see base::read.csv
#' @export
#' @examples \dontrun{
#' zip_file = "data/01.zip"
#' d = rw_import_scot(zip_file)
#' ncol(d) # 74 columns
#' }
rw_import_elgin_restrictions = function(file_path) {
  data <- utils::read.csv(file_path, stringsAsFactors = FALSE)

  data$date_created = lubridate::dmy_hms(data$date_created)
  data$proposed_start_date = lubridate::dmy_hms(data$proposed_start_date)
  data$estimated_end_date = lubridate::dmy_hms(data$estimated_end_date)
  data$restriction_end_date = lubridate::dmy_hms(data$restriction_end_date)
  data$deadline_datetime = lubridate::dmy_hms(data$deadline_datetime)

  #data$publisher = as.factor(data$publisher)
  #data$publisher_district = as.factor(data$publisher_district)
  #data$recipient_district = as.factor(data$recipient_district)
  #data$notification_type_name = as.factor(data$notification_type_name)

  locs = data[,c("ienid","location_bng")]
  locs = locs[locs$location_bng != "",]
  locs$geometry = sf::st_as_sfc(locs$location_bng)
  locs$location_bng = NULL

  data = dplyr::left_join(data,locs, by = "ienid")
  data = sf::st_sf(data)

  return(data)
}

#' Import Elgin ED road works data
#'
#' This function imports data that has already been downloaded from
#' http://downloads.roadworks.org/
#'
#' @param file_path path to csv file or compressed file
#'
#' @details see base::read.csv
#'
#' @examples \dontrun{
#' zip_file = "data/01.zip"
#' d = rw_import_scot(zip_file)
#' ncol(d) # 74 columns
#' }
rw_import_elgin_ed = function(file_path) {
  data <- utils::read.csv(file_path, stringsAsFactors = FALSE)

  data$datetimestamp = lubridate::ymd_hms(data$datetimestamp)
  data$start_date = lubridate::ymd(data$start_date)
  data$end_date = lubridate::ymd(data$end_date)
  data$filter_ds = lubridate::ymd_hms(data$filter_ds)

  # data$lha_name = as.factor(data$lha_name)
  # data$publisher_name = as.factor(data$publisher_name)
  # data$responsible_org_name = as.factor(data$responsible_org_name)
  # data$responsible_org_sector = as.factor(data$responsible_org_sector)
  # data$works_category = as.factor(data$works_category)
  # data$works_state = as.factor(data$works_state)
  # data$impact_score = as.factor(data$impact_score)
  # data$traffman = as.factor(data$traffman)
  # data$roadcategory = as.factor(data$roadcategory)
  # data$permit_status = as.factor(data$permit_status)
  # data$promotertype = as.factor(data$promotertype)
  # data$town_name = as.factor(data$town_name)

  locs = data[,c("id","easting","northing")]
  locs = locs[(!is.na(locs$easting)) & (!is.na(locs$northing)),]
  locs = sf::st_as_sf(locs, coords = c("easting","northing"), crs = 27700)

  data = dplyr::left_join(data,locs,by = "id")
  data = sf::st_sf(data)

  return(data)
}


#' Import Elgin TTVDD road works data
#'
#' This function imports data that has already been downloaded from
#' http://downloads.roadworks.org/
#'
#' @param file_path path to csv file or compressed file
#'
#' @details see base::read.csv
#'
#' @examples \dontrun{
#' d = rw_import_scot("data/01.zip")
#' ncol(d) # 74 columns
#' }
rw_import_elgin_ttvdd = function(file_path) {
  data = utils::read.csv(file_path, stringsAsFactors = FALSE)

  data$timestamp = lubridate::dmy_hms(data$timestamp)

  return(data)
}

#' Bulk Import Elgin road works data
#'
#' This function imports data that has already been downloaded from
#' http://downloads.roadworks.org/
#'
#' @param folder_path path to folder containing csv file or compressed csv file
#' @param method name of import algorithum to use
#' @param pattern character string containing a regular expression. This is used as a filter rule for file names. For example pattern = "test" whold only import files with test in the file name. Passed to base::grepl
#' @param ... additonal variaibles passed to grepl
#'
#' @details
#'
#' A useful pattern is 'pattern = '^(?!.*log).*ttvdd'
#' Which will return all files names with 'ttvdd' but exclude all file names with 'log'
#' You must also pass the perl = TRUE parameter
#'
#' @examples \dontrun{
#' d = rw_import_elgin_batch("C:/data","rw_import_elgin_ttvdd", '^(?!.*log).*ttvdd', perl = TRUE)
#' }
rw_import_elgin_batch = function(folder_path, method = c("ttvdd","ed","restrictions","htdd"), pattern, ...) {
  if(!method %in% c("ttvdd","ed","restrictions","htdd")){
    message("Unknown method: Method must be ttvdd, ed, restrictions, or htdd")
    stop()
  }
  if(substr(folder_path,nchar(folder_path),nchar(folder_path)) != "/"){
    folder_path = paste0(folder_path,"/")
  }

  files = list.files(folder_path, full.names = F)
  if(exists("pattern")){
    files = files[grepl(pattern, files, ...)]
  }
  results = list()
  for(i in seq(1,length(files))){
    message(paste0("Importing ",files[i]))
    path = paste0(folder_path,files[i])
    if(method == "ttvdd"){
      res = rw_import_elgin_ttvdd(path)
    }else if(method == "ed"){
      res = rw_import_elgin_ed(path)
    }else if(method == "restrictions"){
      res = rw_import_elgin_restrictions(path)
    }else if(method == "htdd"){
      res = rw_import_elgin_htdd(path)
    }else{
      message("Catastrophic Error")
      stop()
    }
    results[[i]] = res
    rm(res)
  }

  if(method %in% c("ed","restrictions")){
    results = suppressWarnings(dplyr::bind_rows(results))
    results = as.data.frame(results)
    results$geometry = sf::st_sfc(results$geometry)
    results = sf::st_sf(results)
    sf::st_crs(results) = 27700
  }else if(method %in% c("hddt")){
    results = suppressWarnings(dplyr::bind_rows(results))
    results = as.data.frame(results)
    results$e__location_point = sf::st_sfc(results$e__location_point)
    results$e__location_bng = sf::st_sfc(results$e__location_bng)
    results$i__location_point = sf::st_sfc(results$i__location_point)
    results = sf::st_sf(results)
    sf::st_crs(results) = 27700

  }else{
    results = dplyr::bind_rows(results)
  }

  return(results)

}


#' Clean Spatial Part of the HDDT Data
#'
#' From https://downloads.srwr.scot/export
#' @param df a data frame to clean
#' @export
rw_clean_points = function(df) {
  cols = c("id",
           "e__location_point_easting","e__location_point_northing",
           "e__location_point_bng",
           "e__location_bng",
           "i__location_point_easting","i__location_point_northing",
           "i__location_point_bng")
  df.spatial = df[, cols]

  #Pull Out each of the location types
  locs1 = sf::st_as_sf(df.spatial[,c(2,3)], coords = c("e__location_point_easting","e__location_point_northing"), crs = 27700)
  locs1 = as.data.frame(locs1)
  names(locs1) = c("e__location_point")

  locs3 = df.spatial[,c("id","e__location_bng")]
  locs3 = locs3[locs3$e__location_bng != "",]
  locs3$e__location_bng = sf::st_as_sfc(locs3$e__location_bng)
  locs4 = df.spatial[,c("id","i__location_point_easting","i__location_point_northing")]
  locs4 = locs4[!is.na(locs4$i__location_point_easting) & !is.na(locs4$i__location_point_northing),]
  locs4 = sf::st_as_sf(locs4, coords = c("i__location_point_easting","i__location_point_northing"), crs = 27700)
  names(locs4) = c("id","i__location_point")

  df.spatial = df.spatial[,c("id"), drop=FALSE]
  df.spatial$e__location_point = locs1$e__location_point

  df.spatial = dplyr::left_join(df.spatial, locs3, by = "id")
  df.spatial = dplyr::left_join(df.spatial, locs4, by = "id")


  df = df[,names(df)[!(names(df) %in% cols[2:8])]]
  df = dplyr::left_join(df,df.spatial, by = "id")
  return(df)

}

