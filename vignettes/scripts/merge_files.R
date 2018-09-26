#file_path = "D:/Users/earmmor/OneDrive - University of Leeds/Elgin/HDDT v1/elgin.htdd.export.20180101-20180131.csv"
#file_path2 = "D:/Users/earmmor/OneDrive - University of Leeds/Elgin/HDDT v1/elgin.htdd.export.20180101-20180131.csv.gzip"

folder_path = "D:/Users/earmmor/OneDrive - University of Leeds/Elgin/HDDT v2/"

c("ttvdd","ed","restrictions","hddt")

source("R/rw_import_elgin.R")

ttvdd = rw_import_elgin_batch(folder_path, method = "ttvdd", pattern = "^(?!.*log).*ttvdd", perl = TRUE)
ed = rw_import_elgin_batch(folder_path, method = "ed", pattern = "^(?!.*log).*elgin.ed", perl = TRUE)
restrictions = rw_import_elgin_batch(folder_path, method = "restrictions", pattern = "^(?!.*log).*restrictions", perl = TRUE)
htdd = rw_import_elgin_batch(folder_path, method = "htdd", pattern = "^(?!.*log).*htdd", perl = TRUE)

object.size(htdd)

htdd$entity_type_name = as.factor(htdd$entity_type_name)
htdd$publisher_name = as.factor(htdd$publisher_name)
htdd$responsible_org_name = as.factor(htdd$responsible_org_name)
htdd$responsible_org_sector = as.factor(htdd$responsible_org_sector)
htdd$entity_category = as.factor(htdd$entity_category)
htdd$entity_category_description = as.factor(htdd$entity_category_description)
htdd$e__works_category = as.factor(htdd$e__works_category)
htdd$e__impact_score = as.factor(htdd$e__impact_score)
htdd$e__traffman_code = as.factor(htdd$e__traffman_code)
htdd$e__works_state = as.factor(htdd$e__works_state)
htdd$e__permit_status = as.factor(htdd$e__permit_status)
htdd$e__status = as.factor(htdd$e__status)
htdd$e__works_activity_code = as.factor(htdd$e__works_activity_code)
htdd$e__start_date_estimated = as.factor(htdd$e__start_date_estimated)
htdd$e__end_date_estimated = as.factor(htdd$e__end_date_estimated)
htdd$e__la_name = as.factor(htdd$e__la_name)
htdd$i__item_type = as.factor(htdd$i__item_type)
htdd$i__traffman_code = as.factor(htdd$i__traffman_code)
htdd$i__impact_score = as.factor(htdd$i__impact_score)
htdd$i__works_type = as.factor(htdd$i__works_type)
htdd$i__works_status = as.factor(htdd$i__works_status)
htdd$i__works_state = as.factor(htdd$i__works_state)
htdd$i__works_state_derived = as.factor(htdd$i__works_state_derived)
htdd$i__la_name = as.factor(htdd$i__la_name)

object.size(htdd)


saveRDS(ttvdd,"data/ttvdd_v3.Rds")
saveRDS(ed,"data/ed_v3.Rds")
saveRDS(restrictions,"data/restrictions_v3.Rds")
saveRDS(htdd,"data/htdd_v3.Rds")



