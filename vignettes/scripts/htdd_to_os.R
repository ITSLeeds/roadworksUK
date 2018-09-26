#match to OS
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
tmap_mode("view")
source("R/rw_OS.R")

htdd <- readRDS("data/htdd_v2.Rds")

folder = "D:/Users/earmmor/OneDrive - University of Leeds/Cycling Big Data/OS/MasterMapRoads/MasterMap Highways Network_rami_2408772/"

#result = rw_import_OSMM(folder)
#saveRDS(result,"data/OS_MM_all.Rds")
result = readRDS("data/OS_MM_all.Rds")

RoadLink = result$RoadLink
#Road = result$Road
Street = result$Street

rm(result)
qtm(st_zm(RoadLink[1:100,]))

Street_sub = Street[Street$localId %in% htdd$e__usrn,]
Street_sub = Street_sub[,c("identifier","localId","streetType", "state","nationalRoadCode",
                           "roadClassification","localRoadCode","name","authorityName","town" ,
                           "administrativeArea","locality","descriptor","localName"   )]

qtm(Street_sub[1:1000,])

boundaries = st_read("data/boundaries/ha.gpkg")
boundaries = boundaries[,c("name")]
boundaries = st_transform(boundaries, 27700)



RoadLink_join = st_join(RoadLink,boundaries) # join crashes R
saveRDS(RoadLink_join,"data/OS_RoadLink_HA.Rds")

# Make Summary Statisitcs
RoadLink_summary = as.data.frame(RoadLink_join[,c("identifier","name","length","routeHierarchy")])

RoadLink_summary = RoadLink_summary %>%
  group_by(name, routeHierarchy ) %>%
  summarise(length_km = sum(length)/1000 )

RoadLink_summary = spread(RoadLink_summary, key = routeHierarchy, value = length_km)
RoadLink_summary$total_km = rowSums(RoadLink_summary[,-1], na.rm = T)

saveRDS(RoadLink_summary,"data/HA_RoadStats.Rds")


