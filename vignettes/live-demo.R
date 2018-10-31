# roadworksUK live demo


# set-up ------------------------------------------------------------------

# RStudio

# packages

install.packages("devtools")
install.packages("tidyverse")

# installing roadworks
devtools::install_github("ITSLeeds/roadworkUK")

library(ggplot2)
library(roadworksUK)

library(tidyverse)
library(tmap)
ttm()

names(htdd_ashford)
summary(ht)
roadworks = sf::st_sf(htdd_ashford$i__location_point, htdd_ashford) %>%
  select(id, responsible_org_name, responsible_org_sector, e__date_created, e__start_date,
         e__end_date)
roadworks = roadworks %>%
  filter(e__start_date >= "2018-06-01")

# making a map ------------------------------------------------------------

qtm(roadworks)
tm_basemap(server = leaflet::providers$OpenTopoMap) +
  qtm(htdd_ashford$i__location_point)

# describing the data -----------------------------------------------------

# View(htdd_ashford)
barplot(table(htdd_ashford$responsible_org_sector))

# make a map of just water-related roadworks

# ggplot2


# ggplot2 with theme


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
roadworks$duration = difftime(roadworks$e__end_date, roadworks$e__start_date, units = "days")
summary(roadworks$duration)
roadworks_sector = roadworks %>%
  group_by(responsible_org_sector) %>%
  summarise(duration = median(duration))
ggplot(roadworks_sector) +
  geom_bar(aes(responsible_org_sector, duration), stat = "identity") +
  ylab("Duration (days)")
