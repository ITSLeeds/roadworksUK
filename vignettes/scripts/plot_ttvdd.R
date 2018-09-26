# Plot ttvdd
library(sf)
library(dplyr)
library(tmap)
library(grid)
library(tidyr)

bounds_plot = st_read("data/boundaries/msoa_mod.gpkg")
msoa.summary = readRDS("../roadworksUK/data/htdd_msoa_summary.Rds")

ttvdd.summary = readRDS("data/ttvdd_summary.Rds")
htdd.filter = readRDS("data/htdd_filtered.Rds")
htdd.filter= htdd.filter[!duplicated(htdd.filter$entity_id),]

summary(ttvdd.summary$entity_id %in% htdd.filter$entity_id)
ttvdd.summary.detail = left_join(ttvdd.summary, htdd.filter, by = "entity_id")

ttvdd.summary.org = ttvdd.summary.detail %>%
  group_by(msoa, responsible_org_sector) %>%
  summarise(duration_mins_tt = sum(total_duration)) %>%
  spread(key = responsible_org_sector, value = duration_mins_tt)
ttvdd.summary.org$total = rowSums(ttvdd.summary.org[,-1], na.rm = T)


map = left_join(bounds_plot, ttvdd.summary.org, by = c("id" = "msoa") )

png(filename = "plots/filtered/Disruption.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
  tm_shape(map) +
  tm_fill(col = "total", title = "Total Disruption Minutes", style = "fixed",
          palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
          breaks  = c(0,50,100,500,1000,2000,4000,6000,8000,450000)) +
  tm_layout(legend.position = c(0,0.2),
            #legend.title.size = 1.5,
            #legend.text.size = 1.3,
            frame = FALSE)
dev.off()
