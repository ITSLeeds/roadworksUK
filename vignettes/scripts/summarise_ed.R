library(dplyr)
library(sf)
library(tmap)
library(ggplot2)


ed = readRDS("../roadworksUK/data/ed_v2.Rds")
ed.head = ed[1:100,]

# Separate the ed entity data from the rest of the logs

ed.entity = ed[,c("entity_id","entity_type","lha_name","publisher_orgref",
                  "publisher_name","responsible_org_orgref","responsible_org_name",
                  "responsible_org_sector","works_ref","project_ref","road_name",
                  "description","start_date","end_date","duration",
                  "easting","northing","works_category","works_state","impact_score",
                  "traffman","usrn","is_traffic_sensitive","roadcategory","permit_status",
                  "outofhours","workingdays","weekendworks","promotertype","works_ver_num",
                  "locality_name","town_name","geometry")]
ed.log = ed[,c("id","datetimestamp","log_type_id","entity_id","deeplink_hit","plannedworks_hit")]
ed.log = as.data.frame(ed.log)
ed.log$geometry = NULL
rm(ed)

# Remove Duplicates
ed.entity = ed.entity[!duplicated(ed.entity$entity_id),]
# Note some entity_id have different values, usualy different dates.

# Get some general activity levels
date.summary = as.Date(ed.log$datetimestamp)
date.summary = as.data.frame(table(date.summary))
date.summary$date.summary = as.Date(as.character(date.summary$date.summary))

ggplot(data = date.summary, aes(x = date.summary, y = Freq)) +
  geom_line() +
  stat_smooth(colour='blue', span=0.2) +
  ylab("Number of Enquiries") +
  xlab("Date") +
  labs( title = "Daily Enquiries to roadworks.org") +
  ggsave("plots/Daily_Enquiries.png")

#Group over the week
time.summary = data.frame(datetime = ed.log$datetimestamp, weekday = weekdays(as.Date(ed.log$datetimestamp)), time = strftime(ed.log$datetimestamp, format="%H:%M:%S"))

week2date = function(week){
  if(week == "Monday"){
    return("2018/08/20")
  }else if(week == "Tuesday"){
    return("2018/08/21")
  }else if(week == "Wednesday"){
    return("2018/08/22")
  }else if(week == "Thursday"){
    return("2018/08/23")
  }else if(week == "Friday"){
    return("2018/08/24")
  }else if(week == "Saturday"){
    return("2018/08/25")
  }else if(week == "Sunday"){
    return("2018/08/26")
  }else{
    message("Oh noes!")
    stop()
  }
}

time.summary$weekdate = sapply(time.summary$weekday, week2date)
time.summary$datetime2 = lubridate::ymd_hms(paste0(time.summary$weekdate," ",time.summary$time))
saveRDS(time.summary,"../roadworksUK/data/ed_time_summary.Rds")

time.summary.table = as.data.frame(table(time.summary$datetime2))
time.summary.table$Var1 = lubridate::ymd_hms(time.summary.table$Var1)

ggplot(data = time.summary.table, aes(x = Var1, y = Freq)) +
  geom_line() +
  scale_x_datetime(date_labels = "%a %H:%M:%S", date_breaks = "1 day") +
  #geom_freqpoly(binwidth=30*60) +
  ylab("Number of Enquiries") +
  xlab("Day of the Week") +
  labs( title = "Enquiries to roadworks.org") +
  ggsave("plots/Weekday_Enquiries.png")

# Summarise the logs

ed.log.summary = ed.log %>%
                  group_by(entity_id) %>%
                  summarise(n_views = n(),
                            first_view = min(datetimestamp),
                            last_view = max(datetimestamp),
                            n_deeplink = length(deeplink_hit[deeplink_hit == 1]),
                            n_plannedworks = length(plannedworks_hit[plannedworks_hit == 1]))


saveRDS(ed.log.summary,"../roadworksUK/data/ed_log_summary.Rds")
