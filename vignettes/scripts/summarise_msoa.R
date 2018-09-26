library(sf)
library(dplyr)
library(tmap)
library(grid)
source('../roadworksUK/R/rw_gis.R')

htdd.filter = readRDS("../roadworksUK/data/htdd_filtered.Rds")

bounds = st_read("data/boundaries/msoa.gpkg")
bounds_plot = st_read("data/boundaries/msoa_mod.gpkg")


ids = rw_points_to_region(points = st_sfc(htdd.filter$e__location_point), bounds, ncores = 7)

htdd.filter$msoa = ids

saveRDS(htdd.filter,"../roadworksUK/data/htdd_filtered.Rds")

# Work hour the hours of disruption per work
htdd.filter$e_duration_hours = round(as.numeric(difftime(htdd.filter$e__end_date, htdd.filter$e__start_date, units = "days")),2)
htdd.filter$e_duration_hours[htdd.filter$e_duration_hours < 0] = NA # can have negative duration so remove


# Make some summaries
msoa.summary = htdd.filter %>%
  group_by(msoa) %>%
  summarise(works_total = n(),
            org_HA = length(responsible_org_sector[responsible_org_sector %in% c("Highway Authority","Highway Authority Contractor")]),
            org_Water = length(responsible_org_sector[responsible_org_sector == "Water"]),
            org_Gas = length(responsible_org_sector[responsible_org_sector == "Gas"]),
            org_Tele = length(responsible_org_sector[responsible_org_sector == "Telecommunications"]),
            org_Rail_Tram = length(responsible_org_sector[responsible_org_sector == c("Rail","Tram / Tube")]),
            org_Elec = length(responsible_org_sector[responsible_org_sector == "Electricity"]),
            org_Other = length(responsible_org_sector[responsible_org_sector %in% c("Other","Unknown","Petroleum transmission","National infrastructure" )]),
            org_HE = length(responsible_org_name[responsible_org_name == "Highways England"]),
            impact_Severe = length(e__impact_score[e__impact_score == "Severe"]),
            impact_High = length(e__impact_score[e__impact_score == "High"]),
            impact_Medium = length(e__impact_score[e__impact_score == "Medium"]),
            impact_Low = length(e__impact_score[e__impact_score == "Low"]),
            cat_Emergency = length(e__works_category[e__works_category == "Immediate - Emergency Standard"]),
            cat_Urgent = length(e__works_category[e__works_category == "Immediate - Urgent"]),
            cat_Major = length(e__works_category[e__works_category == "Major"]),
            cat_Minor = length(e__works_category[e__works_category == "Minor"]),
            cat_Undefined = length(e__works_category[e__works_category == "Undefined"]),
            traffman_roadclose = length(e__traffman_code[e__traffman_code == "Road closure"]),
            traffman_noincursion = length(e__traffman_code[e__traffman_code == "No carriageway incursion"]),
            traffman_mulitsignal = length(e__traffman_code[e__traffman_code == "Traffic control (multi-way signals)"]),
            traffman_givetake = length(e__traffman_code[e__traffman_code == "Traffic control (give and take)"]),
            traffman_someincursion = length(e__traffman_code[e__traffman_code == "Some carriageway incursion"]),
            traffman_twoway = length(e__traffman_code[e__traffman_code == "Traffic control (two-way signals)"]),
            traffman_laneclosure = length(e__traffman_code[e__traffman_code == "Lane closure"]),
            traffman_convoy = length(e__traffman_code[e__traffman_code == "Traffic control (convoy working)"]),
            traffman_stopgo = length(e__traffman_code[e__traffman_code == "Traffic control (stop/go boards)"]),
            traffman_priority = length(e__traffman_code[e__traffman_code == "Traffic control (priority working)"]),
            traffman_contraflow = length(e__traffman_code[e__traffman_code == "Contraflow"]),
            traffman_agreedscheme = length(e__traffman_code[e__traffman_code == "Agreed  scheme"]),
            traffman_unknown = length(e__traffman_code[e__traffman_code == "Currently no information (No traffman data)"]),
            duration = sum(e_duration_hours)
            )

msoa.summary$prop_Severe_High = (msoa.summary$impact_Severe + msoa.summary$impact_High) / msoa.summary$works_total * 100


saveRDS(msoa.summary,"../roadworksUK/data/htdd_msoa_summary.Rds")

map = left_join(bounds_plot, msoa.summary, by = c("id" = "msoa") )

png(filename = "plots/filtered/all.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
tm_shape(map) +
  tm_fill(col = "works_total", title = "Total Roadworks", style = "fixed",
          palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
          breaks  = c(0,10,100,500,1000,2000,4000,6000,10000,20000)) +
  tm_layout(legend.position = c(0,0.2))
dev.off()


png(filename = "plots/filtered/Duration.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
  tm_shape(map) +
  tm_fill(col = "duration", title = "Total Duration (Days)", style = "fixed",
          palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
          breaks  = c(0,100,500,1000,2000,4000,6000,10000,20000,125000)) +
  tm_layout(legend.position = c(0,0.2),
            #legend.title.size = 1.5,
            #legend.text.size = 1.3,
            frame = FALSE)
dev.off()

png(filename = "plots/filtered/impact_Severe_High.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
  tm_shape(map) +
  tm_fill(col = "prop_Severe_High", title = "Severe/High Impact Roadworks", style = "fixed",
          palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
          breaks  = c(0,10,20,30,40,50,60,70,80,100)) +
  tm_layout(legend.position = c(0,0.2),
            #legend.title.size = 1.5,
            #legend.text.size = 1.3,
            frame = FALSE)
dev.off()

tmap_mode("plot")
png(filename = "plots/filtered/Sector_facets.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
tm_shape(map) +
  tm_polygons(c("org_HA","org_Water","org_Gas","org_Tele","org_Rail_Tram","org_Elec","org_Other","org_HE"),
             title = "Number of works",
             style = "fixed",
             palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
             breaks = c(0,10,100,200,400,600,800,1000,2000,10000),
             border.col = NULL) +
  #tm_borders() +
  tm_facets(ncol = 3,
            drop.units = T,
            free.scales = F) +
  tm_layout(frame = FALSE,
          panel.show = TRUE,
          panel.labels = c("Highway Authority ","Water","Gas","Telecoms","Rail/Tram","Electricity","Other","Highways England"),
          legend.show = F
          #legend.outside = T,
          #legend.width = 0.2,
          #legend.position = c(-0.8,0)
          )
dev.off()

tmap_mode("plot")
png(filename = "plots/filtered/Sector_facets_ledgend.png" , height = 6, width = 4, units = 'in', res = 600, pointsize=12)
par(mar = c(0.01,0.01,0.01,0.01)) +
  tm_shape(map) +
  tm_polygons(c("org_HA"),
              title = "Number of works",
              style = "fixed",
              palette = c("#d73027","#f46d43","#fdae61","#fee090","#ffffbf","#e0f3f8","#abd9e9","#74add1","#4575b4"),
              breaks = c(0,10,100,200,400,600,800,1000,2000,10000),
              border.col = NULL) +
  #tm_borders() +
  tm_facets(ncol = 3,
            drop.units = T,
            free.scales = F) +
  tm_layout(frame = FALSE,
            panel.show = TRUE,
            panel.labels = c("Highway Authority ","Water","Gas","Telecoms","Rail/Tram","Electricity","Other","Highways England"),
            legend.only = T
            #legend.outside = T,
            #legend.width = 0.2,
            #legend.position = c(-0.8,0)
  )
dev.off()




# map.main = left_join(bounds.mainland, msoa.summary, by = c("id" = "msoa"))
# map.orkney = left_join(bounds.orkney, msoa.summary, by = c("id" = "msoa"))
# map.shetland = left_join(bounds.shetland, msoa.summary, by = c("id" = "msoa"))
#
# plot_map = function(column, filename, title, palette = "RdYlBu", nbreaks = 10, mode = "percentile", breaks = NA, midpoint = NA){
#
#   # inner fucntions
#   percentile = function (dat, nbreaks)
#   {
#     if(all(is.na(dat) | dat == 0)){
#       return(dat)
#     }else{
#       pt1 <- quantile(dat, probs = seq(0, 1, by = 1/nbreaks), type = 7, na.rm = T)
#       pt2 <- unique(as.data.frame(pt1), fromLast = TRUE)
#       pt3 <- rownames(pt2)
#       pt4 <- as.integer(strsplit(pt3, "%"))
#       #breaks = c(0, pt2$pt1)
#       #labels = 1:length(pt3)
#       breaks = c(pt2$pt1)
#       #labels = 1:length(breaks)
#       datp <- pt4[as.integer(cut(dat, breaks, labels = FALSE))]
#       return(datp)
#     }
#   }
#
#   scale_fixed = function (dat, breaks){
#     res = (data - (min(dat)-breaks[1])) * (breaks[length(breaks)] / max(dat))
#     return(res)
#   }
#
#   val2col_fixed = function(dat, breaks, palette = "RdYlBu"){
#     res = cut(dat, breaks, labels = FALSE)
#     pal = RColorBrewer::brewer.pal(length(breaks),palette)
#     colours = pal[res]
#     colours[is.na(colours)] = "#D3D3D3"
#     # labs.val = round(breaks,0)
#     # labs.val = paste0(labels.val[1:nbreaks.tmp]," - ",labels.val[2:(nbreaks.tmp+1)])
#     # labs.val = labs.val[1:length(labs.val)-1]
#     # lables =
#     return(colours)
#   }
#
#
#
#   #select out data
#   map.main.sub = map.main[,column]
#   map.orkney.sub = map.orkney[,column]
#   map.shetland.sub = map.shetland[,column]
#
#   vals = as.data.frame(map.main.sub)
#   vals = vals[,1]
#
#   vals.orkney = as.data.frame(map.orkney.sub)
#   vals.orkney = vals.orkney[,1]
#
#   vals.shetland = as.data.frame(map.shetland.sub)
#   vals.shetland = vals.shetland[,1]
#
#
#   if(mode == "percentile"){
#     map.main.sub$vals.scaled = percentile(vals, nbreaks)
#     map.orkney.sub$vals.scaled = percentile(vals.orkney, nbreaks)
#     map.shetland.sub$vals.scaled = percentile(vals.shetland, nbreaks)
#
#     #format scale
#     labels.val = round(quantile(vals, probs = seq(0,1,0.1), na.rm = T),0)
#     labels = paste0(labels.val[1:nbreaks]," - ",labels.val[2:(nbreaks+1)])
#     labels[1] = paste0(labels[1]," (bottom decile)")
#     labels[nbreaks] = paste0(labels[nbreaks]," (top decile)")
#
#     breaks = seq(0,100,10)
#     if(is.na(midpoint)){
#       midpoint = 50
#     }
#     style = "fixed"
#   }else if(mode == "fixed"){
#     vals[vals == 0] = NA
#     vals.orkney[vals.orkney == 0] = NA
#     vals.shetland[vals.shetland == 0] = NA
#     #s1 = min(vals, na.rm = T)-breaks[1]
#     #s2 = breaks[length(breaks)] / max(vals, na.rm = T)
#     #map.main.sub$vals.scaled = (vals - s1) * s2
#     #map.orkney.sub$vals.scaled = (vals.orkney - s1) * s2
#     #map.shetland.sub$vals.scaled = (vals.shetland - s1) * s2
#     map.main.sub$vals.scaled = val2col_fixed(vals, breaks, palette)
#     map.orkney.sub$vals.scaled = val2col_fixed(vals.orkney, breaks, palette)
#     map.shetland.sub$vals.scaled = val2col_fixed(vals.shetland, breaks, palette)
#     breaks.tmp = c(breaks, 9999999999999999999999)
#     labels.val = round(breaks.tmp,0)
#     nbreaks.tmp = length(breaks.tmp) - 1
#     labels = paste0(labels.val[1:nbreaks.tmp]," - ",labels.val[2:(nbreaks.tmp+1)])
#     labels[length(labels)] = paste0(labels.val[nbreaks], " and over")
#     if(is.na(midpoint)){
#        midpoint = breaks[round(length(breaks)/2,0)]
#     }
#     style = "cat"
#
#
#   }else{
#     vals[vals == 0] = NA
#     vals.orkney[vals.orkney == 0] = NA
#     vals.shetland[vals.shetland == 0] = NA
#     map.main.sub$vals.scaled = vals
#     map.orkney.sub$vals.scaled = vals.orkney
#     map.shetland.sub$vals.scaled = vals.shetland
#
#     #format scale
#     breaks = seq(min(vals, na.rm = T),max(vals, na.rm = T),round(max(vals, na.rm = T)/nbreaks-1))
#     if(is.na(midpoint)){
#       midpoint = mean(vals)
#     }
#
#     labels.val = round(breaks,0)
#     labels = paste0(labels.val[1:nbreaks]," - ",labels.val[2:(nbreaks+1)])
#
#     style = "fixed"
#
#   }
#
#
#   #print(summary(vals))
#   #print(summary(map.main.sub$vals.scaled))
#   #print(midpoint)
#   #hist(map.main.sub$vals.scaled)
#
#   # plot
#   if(tmap_mode() != "plot"){
#     tmap_mode("plot")
#   }
#
#
#
#   tmap.main = tm_shape(map.main.sub) +
#     tm_fill(col = "vals.scaled", title = title, style = style,
#             palette= palette, breaks = breaks,
#             labels = labels, midpoint = midpoint, stretch.palette = FALSE,
#             colorNA = "D3D3D3") +
#     tm_layout(frame = FALSE, bg.color = NA) +
#     tm_legend(legend.outside = TRUE, legend.position = c(-0.3, 0.4))
#
#   tmap.orkney = tm_shape(map.orkney.sub) +
#     tm_fill(col = "vals.scaled" ,style = style, breaks = breaks,
#             palette= palette, midpoint = midpoint, stretch.palette = FALSE) +
#     tm_layout(frame = FALSE, bg.color = NA, legend.show = FALSE)
#
#   tmap.shetland = tm_shape(map.shetland.sub) +
#     tm_fill(col = "vals.scaled", style = style, breaks = breaks,
#             palette= palette, midpoint = midpoint, stretch.palette = FALSE) +
#     tm_layout(frame = FALSE, bg.color = NA, legend.show = FALSE)
#
#   png(filename = filename , height = 5, width = 3.5, units = 'in', res = 600, pointsize=8);
#   print(tmap.main);
#   print(tmap.orkney, vp = viewport(x = 0.7, y = 0.8, width = 0.2, height = 0.1));
#   print(tmap.shetland, vp = viewport(x = 0.9, y = 0.8, width = 0.2, height = 0.2));
#   dev.off()
# }




# plot_map(column = "works_total", "plots/filtered/all.png","Total Roadworks")
# plot_map(column = "prop_Severe_High", filename = "plots/filtered/impact_Severe_High.png", title = "Severe/High Impact Roadworks", nbreaks = 10)
#
# breaks = c(0,50,100,200,500,1000,2000,3000,5000,10000)
#
# plot_map(column = "org_Gas", "plots/filtered/gas.png","Gas Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_HA", "plots/filtered/ha.png","Highway Authority Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_Water", "plots/filtered/water.png","Water Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_Elec", "plots/filtered/electric.png","Electric Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_National", "plots/filtered/national.png","National Infrastrucutre Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_HE", "plots/filtered/HighwaysEngland.png","Highways England Roadworks", breaks = breaks, mode = "fixed")
#
# plot_map(column = "org_Tele", "plots/filtered/Telecoms.png","Telecommunications Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_Rail", "plots/filtered/Rail.png","Railway Roadworks", breaks = breaks, mode = "fixed")
# plot_map(column = "org_Tram", "plots/filtered/Tram.png","Tram Roadworks", breaks = breaks, mode = "fixed")
#
#
#
# plot_map(column = "duration", filename = "plots/filtered/Duration.png", title = "Duration of All Works (Days)", nbreaks = 10, mode = "percentile")
#
#
#
#
#
#
