library(dplyr)
library(sf)
library(tmap)
library(ggplot2)
library(zoo)
# summary of httd data
ttvdd = readRDS("../roadworksUK/data/ttvdd_v2.Rds")
ed = readRDS("../roadworksUK/data/ed_v2.Rds")
restrictions = readRDS("../roadworksUK/data/restrictions_v2.Rds")
htdd = readRDS("../roadworksUK/data/htdd_v3.Rds")

# Top Level Plots
# By Works State
vals = as.character(htdd$e__works_state)
vals[vals == ""] = "Unknown"
vals = as.factor(vals)
png(filename = "plots/works_states.png" , height = 4, width = 6, units = 'in', res = 600, pointsize=12)
par(mar=c(10,6,2,2))
plot(vals, cex = 0.6, cex.sub = 0.6, cex.lab = 0.6, cex.main = 0.6, cex.axis = 0.6, las = 2)
mtext("Works State", side=1, line=8)
mtext("Number of Works", side=2, line=4.5)
dev.off()



# Traffic Control
date.summary = htdd %>%
  mutate(date = as.Date(e__start_date)) %>%
  mutate(month = format(date, format = "%y-%m")) %>%
  filter(date >= as.Date("2016-01-01")) %>%
  filter(date <= as.Date("2019-01-01")) %>%
  group_by(month, e__traffman_code) %>%
  summarise(count = n())

date.summary$e__traffman_code = as.character(date.summary$e__traffman_code)
date.summary$e__traffman_code[date.summary$e__traffman_code == ""] = "Other/ Unspecified"
date.summary$e__traffman_code[date.summary$e__traffman_code %in% c("Agreed  scheme","Footway closure",
                                                                   "Hard Shoulder Closure","Slip Closure",
                                                                   "Road Narrowing (Two Way Working)",
                                                                   "Works Entirely On The Footway",
                                                                   "Traffic control (convoy working)",
                                                                   "Currently no information (No traffman data)",
                                                                   "Contraflow"
                                                                   )] = "Other/ Unspecified"
date.summary = date.summary %>%
  group_by(month, e__traffman_code) %>%
  summarise(count = sum(count))

#date.summary = date.summary[order(-date.summary$count),]

png(filename = "plots/Traffic_Control.png" , height = 4, width = 6, units = 'in', res = 600, pointsize=12)
ggplot(date.summary, aes(month, count, colour = e__traffman_code, group = e__traffman_code))+
  geom_line() +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size = 6), axis.text.y = element_text(size = 6), axis.title = element_text(size=6)) +
  theme(legend.text=element_text(size= 6)) +
  ylab("Number of Works") +
  xlab("Start Year-Month") +
  theme(legend.title=element_blank())
dev.off()


#  Sector
date.summary = htdd %>%
  mutate(date = as.Date(e__start_date)) %>%
  mutate(month = format(date, format = "%y-%m")) %>%
  filter(date >= as.Date("2016-01-01")) %>%
  filter(date <= as.Date("2019-01-01")) %>%
  group_by(month, responsible_org_sector) %>%
  summarise(count = n())

png(filename = "plots/Sector.png" , height = 4, width = 6, units = 'in', res = 600, pointsize=12)
ggplot(date.summary, aes(month, count, colour = responsible_org_sector, group = responsible_org_sector))+
  geom_line() +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size = 6), axis.text.y = element_text(size = 6), axis.title = element_text(size=6)) +
  theme(legend.text=element_text(size= 6)) +
  ylab("Number of Works") +
  xlab("Start Year-Month") +
  theme(legend.title=element_blank())
dev.off()

#  Duration of Works
# only for works that happenned
duration.summary = htdd %>%
  filter(e__works_state %in% c("","Work completed","Work in progress",
                               "Work completed (no excavation)","Work completed (with excavation)",
                               "Planned work about to start")) %>%
  mutate(date = as.Date(e__start_date)) %>%
  mutate(month = format(date, format = "%y-%m")) %>%
  filter(date >= as.Date("2016-01-01")) %>%
  filter(date <= as.Date("2019-01-01")) %>%
  filter(e__duration_days > 0) %>%
  group_by(month) %>%
  summarise(count = n(),
            duration_min = min(e__duration_days),
            duration_10 = quantile(e__duration_days, 0.10),
            duration_25 = quantile(e__duration_days, 0.25),
            duration_50 = quantile(e__duration_days, 0.50),
            duration_75 = quantile(e__duration_days, 0.75),
            duration_90 = quantile(e__duration_days, 0.90),
            duration_mean = mean(e__duration_days),
            duration_max = max(e__duration_days)
            )

png(filename = "plots/Duration.png" , height = 4, width = 6, units = 'in', res = 600, pointsize=12)
ggplot(duration.summary, aes(month))+
  geom_line(aes(y = duration_50,   colour = "Median"), group = 1) +
  geom_line(aes(y = duration_mean, colour = "Mean"), group = 2) +
  coord_cartesian(ylim = c(0, 20)) +
  geom_errorbar(aes(ymin=duration_25, ymax=duration_75), width=.2, position=position_dodge(0.05), color = "grey") +
  theme(axis.text.x = element_text(angle = 90, size = 6), axis.text.y = element_text(size = 6), axis.title = element_text(size=6)) +
  theme(legend.text=element_text(size= 6)) +
  ylab("Average Duration of Works (Days)") +
  xlab("Start Year-Month") +
  theme(legend.title=element_blank())
dev.off()



#names(htdd)

# htdd.summary = summary(htdd)
# unique(htdd$publisher_name)
# unique(htdd$i__la_name)
# unique(htdd$e__la_name)
# summary(htdd$i__la_name == htdd$e__la_name)
# unique(htdd$responsible_org_sector)
# unique(htdd$entity_category)
summary(htdd$e__traffman_code)


# Lets Summarise by Local Authoriy

la.summary = htdd %>%
              group_by(i__la_name) %>%
              summarise(works_total = n(),
                        HA = length(responsible_org_sector[responsible_org_sector == "Highway Authority"]),
                        Water = length(responsible_org_sector[responsible_org_sector == "Water"]),
                        Gas = length(responsible_org_sector[responsible_org_sector == "Gas"]),
                        Tele = length(responsible_org_sector[responsible_org_sector == "Telecommunications"]),
                        Rail = length(responsible_org_sector[responsible_org_sector == "Rail"]),
                        Elec = length(responsible_org_sector[responsible_org_sector == "Electricity"]),
                        Tram = length(responsible_org_sector[responsible_org_sector == "Tram / Tube"]),
                        HAcon = length(responsible_org_sector[responsible_org_sector == "Highway Authority Contractor"]),
                        Other = length(responsible_org_sector[responsible_org_sector == "Other"]),
                        Unknown = length(responsible_org_sector[responsible_org_sector == "Unknown"]),
                        Petrol = length(responsible_org_sector[responsible_org_sector == "Petroleum transmission"]),
                        National = length(responsible_org_sector[responsible_org_sector == "National infrastructure"]),
                        cat_Roadworks = length(entity_category[entity_category == "Roadworks"]),
                        cat_Scaffolding = length(entity_category[entity_category == "Scaffolding"]),
                        cat_Skip = length(entity_category[entity_category == "Skip"]),
                        cat_Plan = length(entity_category[entity_category == "Forward Planning"]),
                        cat_Materials = length(entity_category[entity_category == "Materials"]),
                        cat_Obstruction = length(entity_category[entity_category == "Obstruction"]),
                        cat_Licence = length(entity_category[entity_category == "License (Other) "]),
                        cat_Entertainment = length(entity_category[entity_category == "Entertainment event"]),
                        cat_Party = length(entity_category[entity_category == "Carnival / Parade / Street party"]),
                        cat_Sport = length(entity_category[entity_category == "Sport event"]),
                        cat_Market = length(entity_category[entity_category == "Market"]),
                        cat_Public = length(entity_category[entity_category == "Public event"]),
                        cat_Unclassified = length(entity_category[entity_category == "Unclassified"]),
                        cat_Accident = length(entity_category[entity_category == "Accident"]),
                        cat_Incident = length(entity_category[entity_category == "Incident"]),
                        cat_Weather = length(entity_category[entity_category == "WeatherÂ incident"]),
                        cat_None = length(entity_category[entity_category == ""])
                        )

# plot on a map

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
la.summary$i__la_name = as.character(la.summary$i__la_name)
boundaries$name[boundaries$name == "Bristol, City of"] = "Bristol"
boundaries$name[boundaries$name == "Herefordshire, County of"] = "Herefordshire"
boundaries$name[boundaries$name == "Kingston upon Hull, City of"] = "Kingston upon Hull"
boundaries$name[boundaries$name == "County Durham"] = "Durham"
boundaries$name[boundaries$name == "City of Edinburgh"] = "Edinburgh"
boundaries$name[boundaries$name == "Rhondda Cynon Taf"] = "Rhondda, Cynon, Taf"

miss = la.summary$i__la_name[!(la.summary$i__la_name %in% boundaries$name)]

#note that natioionla orgs and unknown are lost
la.summary.map = left_join(la.summary,boundaries, by = c("i__la_name" = "name"))
la.summary.map = la.summary.map[!is.na(la.summary.map$id),]
la.summary.map = as.data.frame(la.summary.map)
la.summary.map = st_sf(la.summary.map)

png(filename = "plots/all.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "works_total", title = "Total streetworks", n = 10) +
  tm_borders();
dev.off()


# Calcualte Proportions
la.summary.map$pHA = la.summary.map$HA/la.summary.map$works_total * 100
la.summary.map$pWater = la.summary.map$Water/la.summary.map$works_total * 100
la.summary.map$pGas = la.summary.map$Gas/la.summary.map$works_total * 100
la.summary.map$pElec = la.summary.map$Elec/la.summary.map$works_total * 100
la.summary.map$pTele = la.summary.map$Tele/la.summary.map$works_total * 100
la.summary.map$pTran = (la.summary.map$Rail +  la.summary.map$Tram)/la.summary.map$works_total * 100

la.summary.map$cat_Events = la.summary.map$cat_Entertainment + la.summary.map$cat_Party + la.summary.map$cat_Sport + la.summary.map$cat_Market + la.summary.map$cat_Public
la.summary.map$cat_AccIns = la.summary.map$cat_Accident + la.summary.map$cat_Incident


breaks = seq(0,70,5)

png(filename = "plots/HA.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "pHA", title = "Highway Authority works",
          palette = "RdYlBu", breaks = seq(0,100,10), auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/Water.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "pWater", title = "Water works",
          palette = "RdYlBu", breaks = seq(0,100,10), auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/Gas.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "pGas", title = "Gas works",
          palette = "RdYlBu", breaks = seq(0,100,10), auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/Electric.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "pElec", title = "Electric works",
          palette = "RdYlBu", breaks = seq(0,100,10), auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/Telecommunications.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "pTele", title = "Telecommunications works",
          palette = "RdYlBu", breaks = seq(0,100,10), auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/Transport.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "pTran", title = "rail/tram works",
          palette = "RdYlBu", breaks = seq(0,100,10), auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

# counts of non-roadworks things
breaks = c(0,1,100,500,1000,5000,10000,20000,30000,40000)

png(filename = "plots/Scaffolding.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "cat_Scaffolding", title = "Scaffolding", breaks = breaks, auto.palette.mapping=FALSE,
          palette = "YlGn") +
  tm_borders();
dev.off()

png(filename = "plots/Skip.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "cat_Skip", title = "Skips",
          palette = "YlGn", breaks = breaks, auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/Events.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "cat_Events", title = "Events",
          palette = "YlGn", breaks = breaks, auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

png(filename = "plots/AccidentsIncidents.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12);
par(mar = c(0.01,0.01,0.01,0.01));
tm_shape(la.summary.map) +
  tm_fill(col = "cat_AccIns", title = "Accidents and Incidents",
          palette = "YlGn", breaks = breaks, auto.palette.mapping=FALSE) +
  tm_borders();
dev.off()

# Coverage Map

htdd_first = as.data.frame(htdd)
htdd_first = htdd_first %>%
  group_by(i__la_name) %>%
  summarise(date = min(date_created))

htdd_first$publisher = gsub(" City Council", "", htdd_first$publisher)
htdd_first$publisher = gsub(" County Council", "", htdd_first$publisher)
htdd_first$publisher = gsub(" Metropolitan District", "", htdd_first$publisher)
htdd_first$publisher = gsub(" Metropolitan Borough Council", "", htdd_first$publisher)
htdd_first$publisher = gsub(" London Borough", "", htdd_first$publisher)
htdd_first$publisher = gsub(" Council", "", htdd_first$publisher)
htdd_first$publisher = gsub(" Borough", "", htdd_first$publisher)
htdd_first$publisher = gsub(" Royal", "", htdd_first$publisher)

htdd_first$publisher[htdd_first$publisher == "St Helens"] = "St. Helens"
htdd_first$publisher[htdd_first$publisher == "Cheshire West And Chester"] = "Cheshire West and Chester"
htdd_first$publisher[htdd_first$publisher == "Island Roads on behalf of the Isle of Wight"] = "Isle of Wight"

rn = unique(htdd_first$publisher)
bn = unique(bounds$name)

rn[!rn %in% bn]
bn[!bn %in% rn]

map = left_join(bounds, htdd_first, by = c("name" = "publisher"))
map$date = floor_date(map$date,"6 months")
#map$date = as.character(map$date)
#map$date = substr(map$date,1,4)
#map$date = as.numeric(map$date)

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








# Join ttvdd to htdd
ttvdd.summarised2 = rw_summarise_ttvdd(ttvdd, ncores = 7)
saveRDS(ttvdd.summarised2,"../roadworksUK/data/ttvdd_summary.Rds")

htdd.ttvdd = left_join(htdd, ttvdd.summarised2, by = c("entity_id"))
htdd.ttvdd = as.data.frame(htdd.ttvdd)
htdd.ttvdd.summary = htdd.ttvdd %>%
  group_by(
          #i__la_name,
           #responsible_org_sector,
           entity_category,
           #e__works_category,
           #e__impact_score,
           e__traffman_code#,
           #e__status,
           #i__traffman_code,
           #i__impact_score
           ) %>%
  summarise(count = n(),
            count_nodisruption = length(total_duration[is.na(total_duration)]),
            count_disruption = length(total_duration[!is.na(total_duration)]),
            e_duration_total = sum(e__duration_days, na.rm = T),
            impact_total_duration = sum(total_duration, na.rm = T),
            impact_min = min(impact_min, na.rm = T),
            impact_max = max(impact_max, na.rm = T)

            )
