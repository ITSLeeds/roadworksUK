library(dplyr)

rw_summarise_ttvdd = function(ttvdd, ncores = 1){
  # Internal Functions
  # Must be in order
  cluster_times = function(x, tolerance = 10, units = "mins"){
    lng = length(x)
    org = x
    #nxt = x[c(seq(2,lng),lng)]
    pre = x[c(1,seq(1,lng-1))]
    dif = difftime(org, pre, units =  units)
    gap = dif > tolerance
    grp = list()
    grp[[1]] = 1

    for(i in seq(2,lng) ){
      if(gap[i]){
        grp[[i]] = grp[[i-1]] + 1
      }else{
        grp[[i]] = grp[[i-1]]
      }
    }
    grp = unlist(grp)
    return(grp)
  }

  # Group Times
  group_times  = function(i){
    tmp = ttvdd.byentity[[i]]
    tmp = tmp[order(tmp$timestamp),]
    if(nrow(tmp)>1){
      tmp$time_cluster = cluster_times(tmp$timestamp, tolerance = 30, units = "mins")
    }else{
      tmp$time_cluster = 1
    }

    return(tmp)
  }


  entity_ids = unique(ttvdd$entity_id)
  # Group by entity
  if(ncores == 1){
    ttvdd.byentity = lapply(entity_ids,function(x){ttvdd[ttvdd$entity_id == x,]})
  }else{
    CL <- parallel::makeCluster(ncores) #make clusert and set number of core
    parallel::clusterExport(cl = CL, varlist=c("ttvdd"), envir = environment())
    ttvdd.byentity = parallel::parLapply(cl = CL,entity_ids,function(x){ttvdd[ttvdd$entity_id == x,]})
    parallel::stopCluster(CL)
  }

  # Add Time Grouping Number
  if(ncores == 1){
    ttvdd.grouped = lapply(1:length(ttvdd.byentity),group_times)
  }else{
    CL <- parallel::makeCluster(ncores) #make clusert and set number of core
    parallel::clusterExport(cl = CL, varlist=c("ttvdd.byentity"), envir = environment())
    parallel::clusterExport(cl = CL, c("cluster_times"), envir = environment() )
    ttvdd.grouped = parallel::parLapply(cl = CL,1:length(ttvdd.byentity),group_times)
    parallel::stopCluster(CL)
  }
  ttvdd.grouped = dplyr::bind_rows(ttvdd.grouped)

  ttvdd.summarised = ttvdd.grouped[ttvdd.grouped$impact_score > 0, ]
  ttvdd.summarised = dplyr::group_by(ttvdd.summarised, entity_id, time_cluster)
  ttvdd.summarised = dplyr::summarise(ttvdd.summarised,
                                      start = min(timestamp),
                                      end = max(timestamp),
                                      impact_min = min(impact_score),
                                      impact_max = max(impact_score),
                                      counts = n()
                                      )
  ttvdd.summarised$duration = round(as.numeric(difftime(ttvdd.summarised$end, ttvdd.summarised$start, units = "mins")),1)
  ttvdd.summarised$duration[ttvdd.summarised$duration == 0] = 2
  ttvdd.summarised$ppm = ttvdd.summarised$counts/ ttvdd.summarised$duration

  ttvdd.summarised2 = dplyr::group_by(ttvdd.summarised, entity_id)
  ttvdd.summarised2 = dplyr::summarise(ttvdd.summarised2,
                                      numb_events = n(),
                                      total_duration_min = sum(duration),
                                      impact_min = min(impact_min),
                                      impact_max = max(impact_max)
  )


  return(ttvdd.summarised2)

}


ttvdd = readRDS("data/ttvdd_v3.Rds")
ttvdd.summary = rw_summarise_ttvdd(ttvdd, ncores = 6)
saveRDS(ttvdd.summary,"data/ttvdd_summary.Rds")

rm(ttvdd)

htdd = readRDS("data/htdd_v3.Rds")

# remove the things we don't need
htdd$i__location_bng = NULL
htdd$i__location_point = NULL
htdd$e__location_bng = NULL
htdd$e__location_point = NULL
htdd$description = NULL
htdd$project_description = NULL

htdd = htdd[!duplicated(htdd$entity_id),]
htdd = htdd[,c("entity_id","responsible_org_name","responsible_org_sector"
                             ,"e__works_category","e__impact_score",
                             "e__traffman_code","e__duration_days")]

summary(ttvdd.summary$entity_id %in% htdd$entity_id)
ttvdd.summary.detail = left_join(ttvdd.summary, htdd, by = "entity_id")


