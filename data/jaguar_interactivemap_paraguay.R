#Jaguar Datapaper
y1 <- read.csv("jaguar_movement_data.csv", header=T, sep=",")
View(y1)

library (readxl)
y2 <- read_excel("Jaguar_additional information.xlsx", na = "-")
View(y2)

library(dplyr)
#y1 <- y1 %>% count(study.name)
y1 <- y1 %>%
  rename(ID = "individual.local.identifier..ID.",
         lon = "location.long",
         lat = "location.lat",
         tag = "tag.local.identifier") 
y2 <- y2 %>%
  rename(Age = "Estimated Age") 

y3 = merge(y1, y2, by="ID", all.x=F)
View(y3)

y4<- filter(y3, study.name=="Atlantic forest" |
                study.name=="Dry Chaco" |
                study.name=="Humid Chaco" |
                study.name=="Pantanal" |
                study.name=="Paraguayan Pantanal")

library(leaflet)
library(leaflet.extras)
library(leafem)
library(htmlwidgets)

pal <- colorFactor(
  palette = 'Paired',
  domain = y4$ID
)

labs <- lapply(seq(nrow(y4)), function(i) {
  paste0( '<p>', y4[i, "tag"], '<p></p>', 
          y4[i, "Sex"],'</p><p>',
          y4[i, "Age"],'</p><p>',
          y4[i, "Weight"],'</p><p>',
          y4[i, "timestamp"], '<p></p>', 
          y4[i, "lon"],'</p><p>',
          y4[i, "lat"], '<p></p>',
          y4[i, "study.name"],'</p><p>', 
          y4[i, "country"], '</p>' ) 
})

img <- "https://raw.githubusercontent.com/fblpalmeira/jaguar_interactivemap/main/data/onca_colar.png"

leaflet(y4) %>%
  addCircles(lng = ~lon, lat = ~lat, 
             color = ~pal(ID), 
             popup=paste("<b>Jaguar ID:</b>", y4$tag, "<br>",
                         "<b>Gender:</b>", y4$Sex, "<br>", 
                         "<b>Age (years):</b>", y4$Age, "<br>",
                         "<b>Weight (kg):</b>", y4$Weight, "<br>",
                         "<b>Timestamp:</b>", y4$timestamp, "<br>", 
                         "<b>Longitude:</b>", y4$lon, "<br>",
                         "<b>Latitude:</b>", y4$lat, "<br>",
                         "<b>Study name:</b>", y4$study.name, "<br>",
                         "<b>Country:</b>", y4$country)) %>%
  addEasyButton(easyButton(
    icon="fa-globe", title="Zoom",
    onClick=JS("function(btn, map){ map.setZoom(2); }"))) %>%
  addResetMapButton() %>% 
  addMeasure(position="topleft", primaryLengthUnit = "meters", primaryAreaUnit = "hectares") %>%
  addLogo(img, position="topleft", width = 70, height = 35)%>%
  addProviderTiles(providers$Esri.WorldImagery, group = "ESRI World Imagery") %>% 
  addProviderTiles(providers$OpenTopoMap, group = "Open Topo Map") %>% 
  addProviderTiles(providers$OpenStreetMap, group = "Open Street Map") %>%
  addLayersControl(
    baseGroups = c("ESRI World Imagery","Open Topo Map","Open Street Map"),
    options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(toggleDisplay = TRUE) 
