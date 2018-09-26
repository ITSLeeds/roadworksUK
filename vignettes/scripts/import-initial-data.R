# Aim: import, clean and explore initial roadworks data
# Author: Robin Lovelace
# warning: this script was used on a non-standard and out-of-date dataset
# it is retained only for teaching purposes (note the output is shown)

# set-up ------------------------------------------------------------------
setwd("N:/Earth&Environment/Research/ITS/Research-1/CyIPT/elgin-data-project")
library(tidyverse)
# f = list.files(path = "raw-data-1/", pattern = "*.csv", full.names = TRUE)
# # d = map_df(f, read_csv) # fails
# col_types = cols(
#   .default = col_character(),
#   `Publisher OrgRef` = col_integer(),
#   `Grid Reference (Easting)` = col_integer(),
#   `Grid Reference (Northing)` = col_integer(),
#   `Traffic Management Type` = col_integer(),
#   `Works impact` = col_integer(),
#   `Works category` = col_integer(),
#   `Works State` = col_integer()
# )
# d = map_df(f, read_csv, col_types = col_types) # works
# saveRDS(d, "raw-data-1/d.Rds")
d = readRDS("raw-data-1/d.Rds")
pryr::object_size(d)

## 1.45 GB

dim(d)

## [1] 2159580      48

names(d)

##  [1] "Street_Authority"               "Publisher_OrgRef"
##  [3] "Works_Promoter"                 "Promoter_OrgRef"
##  [5] "Promoter_Type"                  "Date_of_last_update"
##  [7] "Works_Promoter_Reference"       "Works_start_date"
##  [9] "Works_end_date"                 "Works_location"
## [11] "USRN"                           "Street_full"
## [13] "Road_Number"                    "Street"
## [15] "Locality"                       "Town"
## [17] "Easting"                        "Northing"
## [19] "Works_Description"              "Traffic_Management"
## [21] "Traffic_Management_Description" "Works_impact"
## [23] "Works_impact_description"       "Works_category"
## [25] "Works_category_Description"     "Works_State"
## [27] "Works_State_Description"        "Works_last_updated_in_Elgin"
## [29] "Street Authority (Publisher)"   "Publisher OrgRef"
## [31] "Works Promoter"                 "Promoter Type"
## [33] "Date of last update"            "Works Promoter Reference"
## [35] "Works location"                 "Street - full"
## [37] "Road Number"                    "Grid Reference (Easting)"
## [39] "Grid Reference (Northing)"      "Works Description"
## [41] "Traffic Management Type"        "Works impact"
## [43] "Works impact description"       "Start Date of Works"
## [45] "End Date of Works"              "Works category"
## [47] "Works State"                    "Works State Description"

# summary(d)
# d_orig = d # create backup copy if testing
# d = sample_n(d, size = 1e2) # for testing on sample of size
summary(d$`Works category`)

##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's
##     0.0     2.0     3.0     2.9     4.0     5.0 1633859

summary(as.factor(d$Works_Description))[1:19]

##                                               Trace, then excavate to repair gas escape and reinstate where possible
##                                                                                                                10179
##                                                    Urgent excavation in highway to locate and repair LV cable fault.
##                                                                                                                 6352
##                                                                                                                 Skip
##                                                                                                                 5930
##                                                                                            CLEAR BLOCKAGE IN FOOTWAY
##                                                                                                                 5326
##                                                                      Locate and excavate 1 blockage in existing duct
##                                                                                                                 4670
##                                                                            Attend, Excavate and Repair Gas Escape...
##                                                                                                                 4588
##                                                                                                 Stoptap Replacements
##                                                                                                                 4411
##                                                                                 Registration of Non-Notifiable Works
##                                                                                                                 4381
## Service Pipe Repair <33mm Fway in Footway. Our intention is tocomplete the Permanent Reinstatement in the same phase
##                                                                                                                 4328
##                                                                                           INSTALL NEW TEE IN FOOTWAY
##                                                                                                                 4254
##                                                                    NO VISIBLE TEE IN FOOTWAY FOR CUSTOMER CONNECTION
##                                                                                                                 4165
##                                                                                   Interim to permanent reinstatement
##                                                                                                                 4082
##                                                                        Excavate 1 location(s) to expose cable damage
##                                                                                                                 4028
##              Install external water meter and Boundary Box at depth of under 1.5 metres with minimum dig with per...
##                                                                                                                 3997
##                                            Trace, then excavate to repair gas escape and reinstate where possible...
##                                                                                                                 3995
##                                                                        CUSTOMER SIDE LEAKAGE SUPPLY PIPE REPLACEMENT
##                                                                                                                 3833
##                                                                                              Replace 1 existing pole
##                                                                                                                 3832
##                                                                                               INSTALL TEE IN FOOTWAY
##                                                                                                                 3760
##                                                                                                       Repair Service
##                                                                                                                 3565

summary(as.factor(d$Traffic_Management))[1:19]

##                   0                   4                  12
##              668438              202498              157030
##                  13                   2                  -1
##              156927              104813               73443
##                   9                   3                   7
##               70433               61080               55857
##                   1                   5 carriageway repairs
##               46848               21739                2388
##                  98        c/w patching                   8
##                2131                1535                1513
##     footway repairs        f/w patching                   6
##                1513                1258                 750
##  CW pothole repairs
##                 709

summary(as.factor(d$Works_category))

##      0      1      2      3      4      5   High    Low Medium   NA's
##  66198 113013 179180 861767 302161 101181   2548   4842   2952 525738

summary(as.factor(d$Works_category_Description))

##                           1                           2
##                         193                         144
##                           3                           4
##                         243                        9649
##                           5           Advanced planning
##                         113                           3
##       Immediate - Emergency          Immediate - Urgent
##                      101181                      302159
##                       Major                       Minor
##                      113013                      861755
## Planned work about to start                    Standard
##                          12                      179177
##                   Undefined            Work in progress
##                       66198                           2
##                        NA's
##                      525738

summary(as.factor(d$Works_State))

##   02/08/2017 13:01:38   04/09/2017 12:01:35   05/07/2017 12:01:38
##                     1                     1                     1
##   08/09/2017 15:32:02   10/08/2017 10:30:37   15/06/2017 17:31:15
##                     1                     1                     1
##   15/06/2017 18:30:27   17/07/2017 15:00:53   18/07/2017 15:31:30
##                     1                     1                     1
##   18/09/2017 10:02:27                     2   24/07/2017 14:31:10
##                     1                 33371                     1
##   24/08/2017 09:31:29   24/08/2017 12:01:36   26/06/2017 10:31:26
##                     1                     1                     1
##   26/07/2017 11:31:39   28/06/2017 12:01:38   28/06/2017 14:01:54
##                     1                     1                     1
##                     3                     4                     5
##                146222                267474                471923
##                     6                     7                     8
##                 70437                167693                466363
## Immediate - Emergency    Immediate - Urgent                 Major
##                   113                  9649                   193
##                 Minor              Standard                  NA's
##                   243                   144                525738

summary(as.factor(d$Works_State_Description))

##                                2                                3
##                                1                               38
##                                4                                7
##                               92                              388
##                                8                Advanced planning
##                             9823                            33371
##      Planned work about to start                   Work cancelled
##                           146222                           167693
##                   Work completed   Work completed (no excavation)
##                           466363                            70437
## Work completed (with excavation)                 Work in progress
##                           471923                           267474
##                             NA's
##                           525755

# questions ---------------------------------------------------------------
# Is there a machine readable EToN classification?
# why are there 2 sets of start/end date columns?
nms = names(d)
nms[grepl("Date", nms)]

## [1] "Date_of_last_update" "Date of last update" "Start Date of Works"
## [4] "End Date of Works"

# clean dates -------------------------------------------------------------
# lubridate::ymd_hms(d$`Date of last update`) # fails
# lubridate::dmy_hms(d$`Date of last update`) # works
d = mutate_at(d, vars(contains("date", ignore.case = TRUE)), lubridate::dmy_hms)

## Warning: 10342 failed to parse.

## Warning: 10349 failed to parse.

## Warning: 17 failed to parse.

## Warning: 10342 failed to parse.

map_dbl(d, ~sum(is.na(.)) / nrow(d)) # lots of NAs - can remove many NA rows later

##               Street_Authority               Publisher_OrgRef
##                     0.24343669                     0.24343669
##                 Works_Promoter                Promoter_OrgRef
##                     0.24385019                     0.24344456
##                  Promoter_Type            Date_of_last_update
##                     0.24466378                     0.24823345
##       Works_Promoter_Reference               Works_start_date
##                     0.24344456                     0.24824132
##                 Works_end_date                 Works_location
##                     0.24345243                     0.36615453
##                           USRN                    Street_full
##                     0.03268599                     0.25010419
##                    Road_Number                         Street
##                     0.88800693                     0.03538883
##                       Locality                           Town
##                     0.72262292                     0.03787172
##                        Easting                       Northing
##                     0.24344456                     0.24344456
##              Works_Description             Traffic_Management
##                     0.24640254                     0.24344456
## Traffic_Management_Description                   Works_impact
##                     0.24344456                     0.24344456
##       Works_impact_description                 Works_category
##                     0.24344456                     0.24344456
##     Works_category_Description                    Works_State
##                     0.24344456                     0.24344456
##        Works_State_Description    Works_last_updated_in_Elgin
##                     0.24345243                     0.24824132
##   Street Authority (Publisher)               Publisher OrgRef
##                     0.75656331                     0.75656331
##                 Works Promoter                  Promoter Type
##                     0.75656470                     0.75716806
##            Date of last update       Works Promoter Reference
##                     0.75656331                     0.75656331
##                 Works location                  Street - full
##                     0.79876365                     0.76215422
##                    Road Number       Grid Reference (Easting)
##                     0.94837191                     0.75659897
##      Grid Reference (Northing)              Works Description
##                     0.75659897                     0.75970374
##        Traffic Management Type                   Works impact
##                     0.75656331                     0.75656331
##       Works impact description            Start Date of Works
##                     0.75656331                     0.75656331
##              End Date of Works                 Works category
##                     0.75656331                     0.75656331
##                    Works State        Works State Description
##                     0.75656331                     0.75656331

# summary: 1/4 of many vars NAs, e.g. easting
na_ws1 = is.na(d$Works_start_date)
na_ws2 = is.na(d$`Start Date of Works`)
sum(na_ws1 & na_ws2) # if there's not a date in 1, usually a date in 2

## [1] 10376

d$Works_start_date[na_ws1] = d$`Start Date of Works`[na_ws1]
d$Works_end_date[na_ws1] = d$`End Date of Works`[na_ws1]
# head(d$`End Date of Works` - d$`Start Date of Works`)
d = mutate(d,
           date = lubridate::as_date(Works_start_date),
           hour_start = lubridate::hour(Works_start_date),
           hour_end = lubridate::hour(Works_end_date),
           wday_start = lubridate::wday(Works_start_date),
           wday_end = lubridate::wday(Works_end_date),
           duration = Works_end_date - Works_start_date
)
d$start_time = cut(d$hour_start, breaks = c(0, 9, 12, 17, 23), labels = c("early morning", "morning", "afternoon", "evening"))
d_hour = group_by(d, start_time) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE)
d_hour2 = group_by(d, start_time) %>%
  summarise(n = n(), duration = mean(as.numeric(duration)) / 3600)
d_hour = cbind(d_hour, d_hour2[-1])
d_hour$duration = d_hour$duration / 24
d_hour$n = d_hour$n / max(d_hour$n)
dh_mini = gather(data = select(d_hour, `Works impact`, `Works category`, start_time, n, duration), key = key, value = value, -start_time)
ggplot(dh_mini) +
  geom_bar(aes(x = key, y = value), stat = "identity") +
  facet_wrap(~start_time, scales = "free") +
  theme(axis.text.x=element_text(angle=45,hjust=1))

## Warning: Removed 1 rows containing missing values (position_stack).

plot of chunk unnamed-chunk-1

# test / redundant code ---------------------------------------------------
# d1 = read_csv(f[1])
# d2 = read_csv(f[2])
# d3 = read_csv(f[3])
# d4 = read_csv(f[4])
# d = bind_rows(d1, d2, d3, d4)
# names(d1)

