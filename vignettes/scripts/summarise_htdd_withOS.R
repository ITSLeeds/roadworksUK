# Summarise by Road Types

htdd = readRDS("../roadworksUK/data/htdd_v3.Rds")
os = readRDS("../roadworksUK/data/OS_MM_all.Rds")

street = os[["Street"]]
road = os[["RoadLink"]]
