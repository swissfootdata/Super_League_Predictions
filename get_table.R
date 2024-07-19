###Aktuelle Tabelle
#Tabellendaten laden
url <- paste0("https://www.transfermarkt.ch/super-league/spieltagtabelle/wettbewerb/C1?saison_id=2023")
webpage <- read_html(url)

data_tabelle <- html_text(html_nodes(webpage,"td"))
data_tabelle <- data_tabelle[50:length(data_tabelle)]
tabelle <- data.frame("team",0,0)
colnames(tabelle) <- c("team","matches","score")

start_tabelle <- which(grepl("1 ",data_tabelle))[1]+2

for (i in seq(start_tabelle,length(data_tabelle),10)) {
  
  team <- data_tabelle[i]
  matches <- data_tabelle[i+1]
  score <- data_tabelle[i+7]
  
  new_data <- data.frame(team,matches,score)
  colnames(new_data) <- c("team","matches","score")
  tabelle <- rbind(tabelle,new_data)
  
}  

tabelle <- tabelle[-1,]
tabelle$team <- trimws(gsub("\n","",tabelle$team))

tabelle$matches <- as.numeric(gsub("-",0,tabelle$matches))
tabelle$score <- as.numeric(gsub("-",0,tabelle$score))

#Anpassen Teams
tabelle$team <- gsub("FC Basel","FC Basel 1893",tabelle$team)
tabelle$team <- gsub("FC St. Gallen","FC St. Gallen 1879",tabelle$team)


tabelle$team[which(grepl("Grasshoppers",tabelle$team))] <- "Grasshopper Club Zürich"
tabelle$team[which(grepl("Winterthur",tabelle$team))] <- "FC Winterthur"
tabelle$team[which(grepl("Stade-Lausanne",tabelle$team))] <- "FC Stade-Lausanne-Ouchy"
tabelle$team[which(grepl("Yverdon",tabelle$team))] <- "Yverdon Sport FC"
tabelle$team[which(grepl("Lausanne[-]Sport",tabelle$team))] <- "FC Lausanne-Sport"

round <- max(tabelle$matches)
print(paste0("Played rounds: ",round))

#tabelle <- tabelle %>%
#  add_row(team = "FC Sion")
###Tabelle vom letzten Spieltag
#Tabellendaten laden
url <- paste0("https://www.transfermarkt.ch/super-league/spieltagtabelle/wettbewerb/C1?saison_id=2024&spieltag=",as.numeric(round)-1)
webpage <- read_html(url)


data_tabelle_old <- html_text(html_nodes(webpage,"td"))
data_tabelle_old <- data_tabelle_old[50:length(data_tabelle_old)]
tabelle_old <- data.frame("team",0,0)
colnames(tabelle_old) <- c("team","matches","score")

start_tabelle <- which(grepl("1 ",data_tabelle_old))[1]+2

for (i in seq(start_tabelle,length(data_tabelle_old),10)) {
  
  team <- data_tabelle_old[i]
  matches <- data_tabelle_old[i+1]
  score <- data_tabelle_old[i+7]
  
  new_data <- data.frame(team,matches,score)
  colnames(new_data) <- c("team","matches","score")
  tabelle_old <- rbind(tabelle_old,new_data)
  
}  

tabelle_old <- tabelle_old[-1,]
tabelle_old$team <- trimws(gsub("\n","",tabelle_old$team))

tabelle_old$matches <- as.numeric(gsub("-",0,tabelle_old$matches))
tabelle_old$score <- as.numeric(gsub("-",0,tabelle_old$score))

#Anpassen Teams
tabelle_old$team <- gsub("FC Basel","FC Basel 1893",tabelle_old$team)
tabelle_old$team <- gsub("FC St. Gallen","FC St. Gallen 1879",tabelle_old$team)
tabelle_old$team <- gsub("Lausanne-Sport","FC Lausanne-Sport",tabelle_old$team)

tabelle_old$team[which(grepl("Grasshoppers",tabelle_old$team))] <- "Grasshopper Club Zürich"
tabelle_old$team[which(grepl("Winterthur",tabelle_old$team))] <- "FC Winterthur"
tabelle_old$team[which(grepl("Stade-Lausanne",tabelle_old$team))] <- "FC Stade-Lausanne-Ouchy"
tabelle_old$team[which(grepl("Yverdon",tabelle_old$team))] <- "Yverdon Sport FC"
tabelle_old$team[which(grepl("Lausanne[-]Sport",tabelle_old$team))] <- "FC Lausanne-Sport"

print(tabelle_old)
