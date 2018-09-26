# make msoa bounds
library(sf)
library(dplyr)
library(tmap)
library(grid)
source('../roadworksUK/R/rw_gis.R')

msoa = st_read("../roadworksUK/data/boundaries/MSOA/MSOA.shp")
msoa = msoa[,c("msoa11cd")]
names(msoa) = c("id","geometry")

scotland = st_read("../roadworksUK/data/boundaries/Scotland/LC_2011_EoR_Scotland.shp")
scotland = scotland[,c("GSS_CODELC")]
names(scotland) = c("id","geometry")

bounds = rbind(msoa,scotland)
bounds = st_transform(bounds, 27700)
bounds$id = as.character(bounds$id)

st_write(bounds,"data/boundaries/msoa.gpkg")
