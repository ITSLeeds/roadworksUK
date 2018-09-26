# filter htdd for common value
library(sf)
library(dplyr)

# assumes you have htdd in the location specified
htdd = readRDS("../roadworksUK/data/htdd_v3.Rds")

#tests
#htdd.kent = htdd[htdd$i__la_name == "Kent",]
#htdd.cumbria = htdd[htdd$i__la_name == "Cumbria",]

# First remove those unusual types that not everybody gathers e.g. skips
entity_category = summary(htdd$entity_category)
par(mar = c(12, 4, 2, 2) + 0.2)
barplot(entity_category, las=2)

htdd.filter = htdd[htdd$entity_category == "Roadworks",]
htdd.others = htdd[htdd$entity_category != "Roadworks",]

# Second remove planned works
htdd.filter = htdd.filter[htdd.filter$e__works_state %in% c("Work completed","Work completed (with excavation)","Work completed (no excavation)","Work in progress"),]

# Remove Columns that are not needed
cols = names(htdd.filter)[!names(htdd.filter) %in%
                            c("project_ref","entity_type","publisher_orgref",
                              "publisher_section_id","publisher_section_name",
                              "publisher_eton_regime","responsible_org_orgref",
                              "responsible_org_section_id","responsible_org_section_name",
                              "e__location_description","e__road_name","e__location_geometry_type",
                              "i__location_description","i__road_name","i__road_number")]
htdd.filter = htdd.filter[,cols]

saveRDS(htdd.filter,"../roadworksUK/data/htdd_filtered.Rds")
#htdd.filter = readRDS("../roadworksUK/data/htdd_filtered.Rds")

# Now group works togther
# Multiple entries can be related to the same major works

htdd.grouped = htdd.filter[1:10000,] %>%
  group_by(works_ref) %>%
  summarise(n_records = n(),
            publisher_name = unique(publisher_name),
            responsible_org_name = unique(responsible_org_name),
            responsible_org_sector = unique(responsible_org_sector),
            entity_category = unique(entity_category),
            entity_category_description = unique(entity_category_description),
            description = unique(description),
            e__date_created = paste(unique(e__date_created), collapse = " "),
            e__date_updated = paste(unique(e__date_updated), collapse = " "),
            e__works_category = unique(e__works_category),
            e__impact_score = unique(e__impact_score),
            e__traffman_code = unique(e__traffman_code),
            e__works_state = paste(unique(e__works_state), collapse = " "),
            e__permit_status = paste(unique(e__permit_status), collapse = " "),
            e__start_date = paste(unique(e__start_date), collapse = " "),
            e__end_date = paste(unique(e__end_date), collapse = " "),
            e__usrn = paste(unique(e__usrn), collapse = " "),
            e__affected_usrns = paste(unique(e__affected_usrns), collapse = " "),
            # e__la_name = unique(e__la_name),
            # e__tomtom__max_impact = unique(e__tomtom__max_impact),
            # e__duration_days = unique(e__duration_days),
            # e__working_weekdays_days = unique(e__working_weekdays_days),
            # e__working_weekends_days = unique(e__working_weekends_days),
            # e__lane_rental = unique(e__lane_rental),
            # i__date_created = unique(i__date_created),
            # i__date_updated = unique(i__date_updated),
            # i__start_date = unique(i__start_date),
            # i__end_date = unique(i__end_date),
            # i__traffman_code = unique(i__traffman_code),
            # i__impact_score = unique(i__impact_score),
            # i__usrn = unique(i__usrn),
            # i__la_name = unique(i__la_name),
            # i__works_type = unique(i__works_type),
            # i__works_state = unique(i__works_state),
            # msoa = unique(msoa),
            # e__location_point = st_union(e__location_point),
            # i__location_point = st_union(i__location_point)
            )
