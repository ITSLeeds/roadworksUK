# roadworksUK live demo


# set-up ------------------------------------------------------------------

# RStudio

# packages

install.packages("devtools")
install.packages("tidyverse")

# installing roadworks
devtools::install_github("ITSLeeds/roadworksUK")

library(tidyverse)
library(roadworksUK)
library(tmap)
tmap_mode("view")

names(htdd_ashford)
roadworks = sf::st_sf(htdd_ashford$i__location_point, htdd_ashford) %>%
  select(id, responsible_org_name, responsible_org_sector, e__date_created, e__start_date,
         e__end_date, i__location_point)
roadworks = roadworks %>%
  filter(e__start_date >= "2018-06-01")

# making a map ------------------------------------------------------------

rw_map(roadworks)
qtm(roadworks)
rw_map_interactive(roadworks)
tm_basemap(server = leaflet::providers$OpenTopoMap) +
  qtm(htdd_ashford$i__location_point)

# visualisation is nice but the strength of R is analysis
# Let's calculated the duration in days of roadworks:
roadworks$duration = difftime(roadworks$e__end_date, roadworks$e__start_date, units = "days")
mean(roadworks$duration)

library(sf)
plot(msoa_ashford$geom)
plot(roadworks, add = T)

# let's find out how many roadworks take place in each part of ashford:
msoa_total = aggregate(x = roadworks[1], by = msoa_ashford, FUN = length)
plot(msoa_total, main = "N. roadworks in Ashford, June 2018")

# Focussing on a single sector:
sum(roadworks$responsible_org_sector == "Water")

roadworks_water = roadworks %>%
  filter(responsible_org_sector == "Water")
msoa_water = aggregate(roadworks_water["duration"], msoa_ashford, FUN = mean)
plot(msoa_water, main = "Average waterwork duration (days)")

# describing the data -----------------------------------------------------

# View(htdd_ashford)
barplot(table(htdd_ashford$responsible_org_sector))

# make a map of just water-related roadworks

# ggplot2
ggplot(roadworks) +
  geom_bar(aes(responsible_org_sector))

# ggplot2 with theme
ggplot(roadworks) +
  geom_bar(aes(responsible_org_sector, fill = responsible_org_sector)) +
  theme_bw() +
  theme(axis.text.x = element_blank())

# analysis ----------------------------------------------------------------

# temporal analysis

roadworks_day = roadworks %>%
  group_by(day = e__start_date) %>%
  summarise(n = n())
ggplot(roadworks_day) +
  geom_line(aes(day, n))

roadworks_week = roadworks_day = roadworks %>%
  group_by(week = lubridate::week(e__start_date)) %>%
  summarise(n = n())
ggplot(roadworks_week) +
  geom_line(aes(week, n))

roadworks_week = roadworks_day = roadworks %>%
  group_by(week = lubridate::week(e__start_date), sector = responsible_org_sector) %>%
  summarise(n = n())
ggplot(roadworks_week) +
  geom_line(aes(week, n, color = sector))

# length of time by org
summary(roadworks$duration)
roadworks_sector = roadworks %>%
  group_by(responsible_org_sector) %>%
  summarise(duration = median(duration))
ggplot(roadworks_sector) +
  geom_bar(aes(responsible_org_sector, duration), stat = "identity") +
  ylab("Duration (days)")

