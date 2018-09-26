# Restrictions
library(sf)
library(dplyr)
library(lubridate)

restrictions = readRDS("data/restrictions_v3.Rds")
bounds = st_read("data/boundaries/ha_mod.gpkg", stringsAsFactors = F)

#Fix HA Names
restrictions$publisher = gsub(" City Council", "", restrictions$publisher)
restrictions$publisher = gsub(" County Council", "", restrictions$publisher)
restrictions$publisher = gsub(" Metropolitan District", "", restrictions$publisher)
restrictions$publisher = gsub(" Metropolitan Borough Council", "", restrictions$publisher)
restrictions$publisher = gsub(" London Borough Council", "", restrictions$publisher)
restrictions$publisher = gsub(" Council", "", restrictions$publisher)
restrictions$publisher = gsub(" Borough", "", restrictions$publisher)
restrictions$publisher = gsub(" Royal", "", restrictions$publisher)

restrictions$publisher[restrictions$publisher == "St Helens"] = "St. Helens"
restrictions$publisher[restrictions$publisher == "Cheshire West And Chester"] = "Cheshire West and Chester"
restrictions$publisher[restrictions$publisher == "Island Roads on behalf of the Isle of Wight"] = "Isle of Wight"


# find first for each HA

res_first = as.data.frame(restrictions)
res_first = res_first %>%
  group_by(publisher) %>%
  summarise(date = min(date_created))

rn = unique(res_first$publisher)
bn = unique(bounds$name)

rn[!rn %in% bn]
bn[!bn %in% rn]

map = left_join(bounds, res_first, by = c("name" = "publisher"))
map$date = floor_date(map$date,"6 months")


tmap_mode("plot")
png(filename = "plots/Restrictions_First.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
  tm_shape(map) +
  tm_fill(col = "date", title = "Restrictions Data Coverage", style = "fixed",
          breaks  = c(2013,2014,2015,2016,2017,2018),
          palette = c("-Blues")
          ) +
  tm_layout(legend.position = c(0,0.2),
            #legend.title.size = 1.5,
            #legend.text.size = 1.3,
            frame = FALSE)
dev.off()

# Simplify works to a single record per restriction
restrictions = as.data.frame(restrictions[,c("ienid","date_created","publisher","notification_type_name","works_ref",
                               "notification_sequence_number","usrn","restriction_end_date","restriction_duration" )])

restrictions_group = restrictions %>%
  group_by(works_ref) %>%
  summarise(date_start = min(date_created),
            publisher = unique(publisher)[1],
            #ursn = unique(usrn)[!is.na(unique(usrn))],
            ursn = paste(unique(usrn)[!is.na(unique(usrn))], collapse = " "),
            duration = unique(restriction_duration)[!is.na(unique(restriction_duration))][1],
            records = n())

restrictions_HA = restrictions_group %>%
  filter(date_start > as.Date("2017-01-01")) %>%
  group_by(publisher) %>%
  summarise(count = n())

map = left_join(bounds, restrictions_HA, by = c("name" = "publisher") )
tmap_mode("plot")
png(filename = "plots/Restrictions_Count.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
  tm_shape(map) +
  tm_fill(col = "count", title = "Restrictions Jan 2017 - Jul 2018", style = "fixed",
          palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
          breaks  = c(0,25,50,100,150,200,300,500,1000,1600)) +
  tm_layout(legend.position = c(0,0.2),
            #legend.title.size = 1.5,
            #legend.text.size = 1.3,
            frame = FALSE)
dev.off()
