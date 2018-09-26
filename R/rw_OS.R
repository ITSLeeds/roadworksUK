# Function TO Read in OS MasterMap map GML

#' @param folder character, path to folder of GML.gz file of OSMM
#' Return a named list of SF data frames.
#' N.B. non-spatial GML files not yet supported

rw_import_OSMM = function(folder){
  files = list.files(folder, full.names = F)
  files = files[grepl("gml.gz",files)]
  files = files[!grepl("properties",files)]

  # Break out each type of file
  sep_files = function(name){
    name = files[grepl(name,files)]
    if(length(name) > 0){
      name = paste0(folder,"/",name)
    }
    return(name)
  }

  files_AccessRestriction = sep_files("AccessRestriction")
  files_Dedication = sep_files("Dedication")
  files_FerryLink = sep_files("FerryLink")
  files_FerryNode = sep_files("FerryNode")
  files_FerryTerminal = sep_files("FerryTerminal")
  files_Hazard = sep_files("Hazard")
  files_Maintenance = sep_files("Maintenance")
  files_Reinstatement = sep_files("Reinstatement")
  files_RestrictionForVehicles = sep_files("RestrictionForVehicles")
  files_Road = sep_files("Road_")
  files_RoadLink = sep_files("RoadLink")
  files_RoadNode = sep_files("RoadNode")
  files_SpecialDesignation = sep_files("SpecialDesignation")
  files_Street = sep_files("Street")
  files_Structure = sep_files("Structure")
  files_TurnRestriction = sep_files("TurnRestriction")


  # Read In Data
  AccessRestriction = import_GML(files_AccessRestriction, "AccessRestriction")
  Dedication = import_GML(files_Dedication, "Dedication")
  FerryLink = import_GML(files_FerryLink, "FerryLink")
  FerryNode = import_GML(files_FerryNode, "FerryNode")
  FerryTerminal = import_GML(files_FerryTerminal, "FerryTerminal")
  Hazard = import_GML(files_Hazard, "Hazard")
  Maintenance = import_GML(files_Maintenance, "Maintenance")
  Reinstatement = import_GML(files_Reinstatement, "Reinstatement")
  RestrictionForVehicles = import_GML(files_RestrictionForVehicles, "RestrictionForVehicles")
  Road = import_GML(gml = files_Road, name = "Road")
  RoadLink = import_GML(files_RoadLink, "RoadLink")
  RoadNode = import_GML(files_RoadNode, "RoadNode")
  SpecialDesignation = import_GML(files_SpecialDesignation, "SpecialDesignation")
  Street = import_GML(files_Street, "Street")
  Structure = import_GML(files_Structure, "Structure")
  TurnRestriction = import_GML(files_TurnRestriction, "TurnRestriction")

  #Make a list of outputs

  result = list(AccessRestriction,Dedication,FerryLink,FerryNode,FerryTerminal,
                Hazard,Maintenance,Reinstatement,RestrictionForVehicles,
                Road,RoadLink,RoadNode,SpecialDesignation,Street,Structure,TurnRestriction)

  names(result) = c("AccessRestriction","Dedication","FerryLink","FerryNode","FerryTerminal",
                    "Hazard","Maintenance","Reinstatement","RestrictionForVehicles",
                    "Road","RoadLink","RoadNode","SpecialDesignation","Street","Structure","TurnRestriction")

  return(result)

}

# Internal fucntion for importina a gml file

import_GML = function(gml, name){
  if(length(gml) == 0){
    message(paste0("No ",name," files found"))
    return(NA)
  }else{
    if(name %in% c("!FerryTerminal","!Road","!TurnRestriction")){
      #data = try(lapply(gml, XML::xmlToDataFrame))
      #data = suppressWarnings(dplyr::bind_rows(data))
      message(paste0(name, " not yet supported"))
      return(NA)
    }else{
      message(paste0(Sys.time(),": Importing ",length(gml)," ",name," file(s)"))
      data = try(lapply(gml, sf::read_sf, quiet = T, stringsAsFactors = F))
      if(class(data) == "try-error"){
        message(paste0("Error reading ",name," files"))
        return(NA)
      }else{
        # Clean if needed
        if(name == "RoadLink"){
          data = lapply(data,function(x){x[,names(x)[names(x) != "junctionNumber"]]})
          message("The field  'junctionNumber' is not supported")
        }
        if(name == "Street"){
          #data = lapply(data,function(x){x[,names(x)[!names(x) %in% c("administrativeArea","authorityName")]]})
          data = lapply(data,unlist_gml)

          #message("The fields  'administrativeArea' and 'authorityName' are not supported")
        }
        if(name == "RoadNode"){
          data = lapply(data,function(x){x[,names(x)[names(x) != "junctionName"]]})
          message("The field  'administrativeArea' is not supported")
        }

        data = suppressWarnings(dplyr::bind_rows(data))
        data = as.data.frame(data)
        data$geometry = sf::st_sfc(data$geometry, crs = 27700)
        data = sf::st_sf(data)

        #Clean Columns
        data$gml_id = NULL
        data$identifier = gsub("http://data.os.uk/id/","",data$identifier)
        data$namespace = NULL
        if("beginLifespanVersion" %in% names(data)){
          data$beginLifespanVersion = lubridate::ymd_hms(data$beginLifespanVersion)
        }
        if("beginPosition" %in% names(data)){
          data$beginPosition = lubridate::ymd_hms(data$beginPosition)
        }

        return(data)
      }
    }
  }
}

# Function to handel some field that have lists of length = 1
unlist_gml = function(df){
  listcols = unlist(sapply(df,class))
  listcols = names(listcols)[listcols == "list"]
  message(paste0("Some data is lost while importings the following fields:  '",paste(listcols, collapse = "', '"),"'"))
  for(x in listcols){
    if(all(lengths(df[[x]]) <= 1)){
      df[[x]] = unlist(df[[x]])
    }else{
      df[[x]] = sapply(df[[x]], function(y){if(length(y) == 0){NA}else{y[[1]]}})
    }
  }
  return(df)
}

