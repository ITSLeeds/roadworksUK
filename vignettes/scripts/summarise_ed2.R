library(dplyr)
library(sf)
library(tmap)
library(ggplot2)
library(lubridate)
library(zoo)


ed = readRDS("../roadworksUK/data/ed_v3.Rds")
#ed.head = ed[1:100,]

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
  ylab("Number of Daily Enquiries") +
  xlab("Date") +
  labs( title = "Daily Enquiries to roadworks.org") +
  ggsave("plots/Daily_Enquiries.png")



ed.oneweek = ed.log[ed.log$datetimestamp >= ymd_hms("2018-04-09 00:00:00"),]
ed.oneweek = ed.oneweek[ed.oneweek$datetimestamp <= ymd_hms("2018-04-15 23:59:59"),]
ed.oneweek.summary = ed.oneweek %>%
  mutate(interval = floor_date(datetimestamp, unit="5 mins")) %>%
  group_by(interval) %>%
  summarise(number = n())


ggplot(data = ed.oneweek.summary, aes(x = interval, y = number)) +
    geom_line( ) +
    #scale_x_datetime(date_labels = "%a %H:%M:%S", date_breaks = "1 day") +
    #geom_line(aes(y=rollmean(number, 12, na.pad=TRUE))) +
  #geom_smooth(n = 100, se = F, method = "auto") +
    ylab("Number of Enquiries") +
    xlab("Day of the Week") +
    labs( title = "Enquiries to roadworks.org 9th - 15th April 2018") +
    ggsave("plots/Weekday_Enquiries_oneweek.png")


#Group over the week
# time.summary = data.frame(datetime = ed.log$datetimestamp, weekday = weekdays(as.Date(ed.log$datetimestamp)), time = strftime(ed.log$datetimestamp, format="%H:%M:%S"))
#
# week2date = function(week){
#   if(week == "Monday"){
#     return("2018/08/20")
#   }else if(week == "Tuesday"){
#     return("2018/08/21")
#   }else if(week == "Wednesday"){
#     return("2018/08/22")
#   }else if(week == "Thursday"){
#     return("2018/08/23")
#   }else if(week == "Friday"){
#     return("2018/08/24")
#   }else if(week == "Saturday"){
#     return("2018/08/25")
#   }else if(week == "Sunday"){
#     return("2018/08/26")
#   }else{
#     message("Oh noes!")
#     stop()
#   }
# }

# time.summary$weekdate = sapply(time.summary$weekday, week2date)
# time.summary$datetime2 = lubridate::ymd_hms(paste0(time.summary$weekdate," ",time.summary$time))
# saveRDS(time.summary,"../roadworksUK/data/ed_time_summary.Rds")
#
# time.summary.table = as.data.frame(table(time.summary$datetime2))
# time.summary.table$Var1 = lubridate::ymd_hms(time.summary.table$Var1)
#
# ggplot(data = time.summary.table, aes(x = Var1, y = Freq)) +
#   geom_line() +
#   scale_x_datetime(date_labels = "%a %H:%M:%S", date_breaks = "1 day") +
#   #geom_freqpoly(binwidth=30*60) +
#   ylab("Number of Enquiries") +
#   xlab("Day of the Week") +
#   labs( title = "Enquiries to roadworks.org") +
#   ggsave("plots/Weekday_Enquiries.png")

# Summarise the logs

ed.log.summary = ed.log %>%
                  group_by(entity_id) %>%
                  summarise(n_views = n(),
                            first_view = min(datetimestamp),
                            last_view = max(datetimestamp),
                            n_deeplink = length(deeplink_hit[deeplink_hit == 1]),
                            n_plannedworks = length(plannedworks_hit[plannedworks_hit == 1]))


saveRDS(ed.log.summary,"../roadworksUK/data/ed_log_summary.Rds")

ed.log.summary = left_join(ed.log.summary, ed.entity, by = c("entity_id"))
ed.log.summary = ed.log.summary[order(-ed.log.summary$n_views),]


ed.log.summary2 = ed.log.summary[!is.na(ed.log.summary$n_views),]
ed.log.summary2 = ed.log.summary2[!is.na(ed.log.summary2$duration),]
ed.log.summary2 = ed.log.summary2[ed.log.summary2$n_views > 50 & ed.log.summary2$n_views < 5000,]
ed.log.summary2 = ed.log.summary2[ed.log.summary2$duration < 1000 & ed.log.summary2$duration > 0,]
#plot(ed.log.summary2$duration, ed.log.summary2$n_views, xlab = "Duration in Days", ylab = "Number of Views", pch= ".")
ed.log.summary2$works_category[ed.log.summary2$works_category == ""] = "Unknown"

ggplot(data = ed.log.summary2, aes(x = duration, y = n_views, col = works_category)) +
  geom_point(size = 0.2) +
  #scale_x_datetime(date_labels = "%a %H:%M:%S", date_breaks = "1 day") +
  #geom_line(aes(y=rollmean(number, 12, na.pad=TRUE))) +
  #geom_smooth(n = 100, se = F, method = "auto") +
  ylab("Total Number of Views") +
  xlab("Duration in Days") +
  labs(color='Works Severity') +
  labs( title = "Duration and views on roadworks.org") +
  theme(legend.position = c(1, 1),
       legend.justification = c(1, 1),
       legend.background = element_rect(colour = NA, fill = "white")) +
  guides(colour = guide_legend(override.aes = list(size=2))) +
  ggsave("plots/Views_vs_Duration.png")

