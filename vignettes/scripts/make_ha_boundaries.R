# Make Regions
library(sf)
library(tmap)
tmap_mode("view")


la = st_read("data/boundaries/LA_2017_Ultra_Generalised/LA.shp")
la = la[,c("lad17cd","lad17nm","geometry")]
names(la) = c("id","name","geometry")
counties = st_read("data/boundaries/Counties_UA_Generalised/C_UA.shp")
counties = counties[,c("ctyua17cd","ctyua17nm","geometry")]
names(counties) = c("id","name","geometry")

boundaries = rbind(la,counties)

boundaries = boundaries[!duplicated(boundaries$id),]


# some names need changing
boundaries$name = as.character(boundaries$name)
#la.summary$i__la_name = as.character(la.summary$i__la_name)
boundaries$name[boundaries$name == "Bristol, City of"] = "Bristol"
boundaries$name[boundaries$name == "Herefordshire, County of"] = "Herefordshire"
boundaries$name[boundaries$name == "Kingston upon Hull, City of"] = "Kingston upon Hull"
boundaries$name[boundaries$name == "County Durham"] = "Durham"
boundaries$name[boundaries$name == "City of Edinburgh"] = "Edinburgh"
boundaries$name[boundaries$name == "Rhondda Cynon Taf"] = "Rhondda, Cynon, Taf"
boundaries$name[boundaries$name == "Na h-Eileanan Siar"] = "Na H-Eileanan an Iar"


#miss = la.summary$i__la_name[!(la.summary$i__la_name %in% boundaries$name)]
st_crs(boundaries) = 27700
qtm(boundaries)
st_write(boundaries,"data/boundaries/ha.gpkg", delete_dsn = T)

#boundaries2 = st_read("data/boundaries/ha.gpkg")
