#Get current data
mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")
dbGetQuery(mydb, "SET NAMES 'utf8'")

rs <- dbSendQuery(mydb, "SELECT * FROM matches_database")
matches_database <- fetch(rs,n=-1, encoding="utf8")
Encoding(matches_database$team_home) <- "UTF-8"
Encoding(matches_database$team_away) <- "UTF-8"
Encoding(matches_database$referee) <- "UTF-8"

dbDisconnectAll()

#Transform data
matches_database$date <- as.Date(matches_database$date)
matches_database[matches_database == 999] <- NA

#New data frame
upcoming_matches <- data.frame("team_home","team_away",0,0,1,"01.01.1900","99:99","Schiedsrichter")
colnames(upcoming_matches) <- c("team_home","team_away","team_home_ranking","team_away_ranking",
                                "round","date","time","referee")

for (i in new_matches_all) {
  
  url <- paste0("https://www.transfermarkt.ch/fc-sion_fc-basel-1893/statistik/spielbericht/",i)
  webpage <- read_html(url)
  
  team_home <- html_text(html_nodes(webpage,".sb-vereinslink"))[1]
  team_away <- html_text(html_nodes(webpage,".sb-vereinslink"))[2]
  #team_home <- gsub("FC Lausanne-Sport","FC Winterthur",team_home)
  #team_away <- gsub("FC Lausanne-Sport","FC Winterthur",team_away)
  team_home_ranking <- which(tabelle$team == team_home)
  team_away_ranking <- which(tabelle$team == team_away)
  
  spieltag <- parse_number(html_text(html_nodes(webpage,".sb-datum"))[1])
  datum <- gsub( ".*(\\d{2}.\\d{2}.\\d{2}).*", "\\1", html_text(html_nodes(webpage,".sb-datum"))[1])
  datum <- gsub("[.]22",".2022",datum)
  #datum <- gsub("[.]21",".2022",datum) 
  datum <- gsub("[.]23",".2023",datum)
  datum <- gsub("[.]24",".2024",datum)
  datum <- gsub("[.]25",".2025",datum)
  datum <- gsub("[.]26",".2026",datum)
  datum <- gsub("[.]27",".2027",datum)
  datum <- gsub("[.]28",".2028",datum)
  zeit <- gsub( ".*(\\d{2}:\\d{2}).*", "\\1", html_text(html_nodes(webpage,".sb-datum"))[1])

  schiedsrichter <- str_split(html_text(html_nodes(webpage,".sb-zusatzinfos")),"Schiedsrichter:")[[1]][2]
  schiedsrichter <- trimws(gsub("\t","",schiedsrichter))
  
  #Write in dataframe
  new_data <- data.frame(team_home,team_away,team_home_ranking,team_away_ranking,
                         spieltag,datum,zeit,schiedsrichter)
  colnames(new_data) <- c("team_home","team_away","team_home_ranking","team_away_ranking",
                                  "round","date","time","referee")
  
  upcoming_matches <- rbind(upcoming_matches,new_data)
  
  print("scraping completed")
  print(team_home)
  print(nrow(upcoming_matches)-1)
  
}

#Write in dataframe
upcoming_matches <- upcoming_matches[-1,]
upcoming_matches$date <- as.Date(upcoming_matches$date,format="%d.%m.%Y")


for (i in 1:nrow(upcoming_matches)) {
  
  if (upcoming_matches$team_home_ranking[i] > 12) {
     upcoming_matches$team_home_ranking[i] <- NA
    
   } 
  
  if (is.na(upcoming_matches$team_home_ranking[i]) == TRUE) {
    
    selection <- upcoming_matches[upcoming_matches$team_home == upcoming_matches$team_home[i] | 
                                    upcoming_matches$team_away == upcoming_matches$team_home[i],]
    
    selection <- selection[!is.na(selection$team_away_ranking),]
    selection <- selection[nrow(selection),]
    
    if (selection$team_home == upcoming_matches$team_home[i]) {
      upcoming_matches$team_home_ranking[i] <- selection$team_home_ranking 
    } else {
      upcoming_matches$team_home_ranking[i] <- selection$team_away_ranking
    } 
  }
  
  if (is.na(upcoming_matches$team_away_ranking[i]) == TRUE) {
    
    selection <- upcoming_matches[upcoming_matches$team_away == upcoming_matches$team_away[i] | 
                                    upcoming_matches$team_home == upcoming_matches$team_away[i],]
    
    selection <- selection[!is.na(selection$team_away_ranking),]
    selection <- selection[nrow(selection),]
    if (selection$team_away == upcoming_matches$team_away[i]) {
      upcoming_matches$team_away_ranking[i] <- selection$team_away_ranking 
    } else {
    upcoming_matches$team_away_ranking[i] <- selection$team_home_ranking
    } 
  }
}


#Adapt Date
upcoming_matches$date <- gsub("0022","2022",upcoming_matches$date)
upcoming_matches$date <- as.Date(upcoming_matches$date)


#Add form data
upcoming_matches$points_home <- NA
upcoming_matches$points_away <- NA
upcoming_matches$threemonths_performance_home <- NA
upcoming_matches$threemonths_performance_away <- NA
upcoming_matches$year_performance_home <- NA
upcoming_matches$year_performance_away <- NA
upcoming_matches$threeyear_performance_home <- NA
upcoming_matches$threeyear_performance_away <- NA

old_matches <- matches_database %>%
  select(team_home,team_away,
         team_home_ranking,team_away_ranking,round,date,time,referee,
         points_home,points_away,
         threemonths_performance_home,threemonths_performance_away,
         year_performance_home,year_performance_away,
         threeyear_performance_home,threeyear_performance_away)

all_matches <- rbind(old_matches,upcoming_matches)

for (i in (nrow(all_matches)-length(new_matches)):nrow(all_matches)) {
  
  team <- all_matches$team_home[i]  
  date <- all_matches$date[i]
  last_three_months <- all_matches[all_matches$date > date-90 & all_matches$date < date & all_matches$team_home == team,]
  performance <- mean(last_three_months$points_home, na.rm = TRUE)
  all_matches$threemonths_performance_home[i] <- performance
  
}
for (i in (nrow(all_matches)-length(new_matches)):nrow(all_matches)) {
  
  team <- all_matches$team_away[i]  
  date <- all_matches$date[i]
  last_three_months <- all_matches[all_matches$date > date-90 & all_matches$date < date & all_matches$team_away == team,]
  performance <- mean(last_three_months$points_away, na.rm = TRUE)
  all_matches$threemonths_performance_away[i] <- performance
  
}
for (i in (nrow(all_matches)-length(new_matches)):nrow(all_matches)) {
  
  team <- all_matches$team_home[i]  
  date <- all_matches$date[i]
  last_year <- all_matches[all_matches$date > date-365 & all_matches$date < date & all_matches$team_home == team,]
  performance <- mean(last_year$points_home, na.rm = TRUE)
  all_matches$year_performance_home[i] <- performance
  
}
for (i in (nrow(all_matches)-length(new_matches)):nrow(all_matches)) {
  
  team <- all_matches$team_away[i]  
  date <- all_matches$date[i]
  last_year <- all_matches[all_matches$date > date-365 & all_matches$date < date & all_matches$team_away == team,]
  performance <- mean(last_year$points_away, na.rm = TRUE)
  all_matches$year_performance_away[i] <- performance
  
}
for (i in (nrow(all_matches)-length(new_matches)):nrow(all_matches)) {
  
  team <- all_matches$team_home[i]  
  date <- all_matches$date[i]
  last_threeyears <- all_matches[all_matches$date > date-1095 & all_matches$date < date & all_matches$team_home == team,]
  performance <- mean(last_threeyears$points_home, na.rm = TRUE)
  all_matches$threeyear_performance_home[i] <- performance
  
}
for (i in (nrow(all_matches)-length(new_matches)):nrow(all_matches)) {
  
  team <- all_matches$team_away[i]  
  date <- all_matches$date[i]
  last_threeyears <- all_matches[all_matches$date > date-1095 & all_matches$date < date & all_matches$team_away == team,]
  performance <- mean(last_threeyears$points_away, na.rm = TRUE)
  all_matches$threeyear_performance_away[i] <- performance
  
}

#Replace NAs
for(i in 1:ncol(all_matches)){
  all_matches[is.na(all_matches[,i]), i] <- mean(all_matches[,i], na.rm = TRUE)
}

upcoming_matches <- all_matches[(nrow(all_matches)-length(new_matches_all)+1):nrow(all_matches),]

upcoming_matches$points_home <- NA
upcoming_matches$points_away <- NA

#Add Elo
upcoming_matches$elo_home <- NA
upcoming_matches$elo_away <- NA

for (y in 1:nrow(upcoming_matches)) {
  
  date <- upcoming_matches$date[y]-1

  elo_home <- elo_values[elo_values$Club == upcoming_matches$team_home[y],]
  elo_home <- elo_home[elo_home$To <= date,5]
  upcoming_matches$elo_home[y] <- elo_home[length(elo_home)]
  
  
  elo_away <- elo_values[elo_values$Club == upcoming_matches$team_away[y],]
  elo_away <- elo_away[elo_away$To <= date,5]
  upcoming_matches$elo_away[y] <- elo_away[length(elo_away)]
  
  
}
upcoming_matches$team_home[y]
#Add average market value
#season
upcoming_matches$season <- season

#Marktwerte
market_values_home <- market_values
colnames(market_values_home) <- c("season","team_home","mv_overall_home","mv_average_home","mv_ranking_home")
upcoming_matches <- merge(upcoming_matches,market_values_home)

market_values_away <- market_values
colnames(market_values_away) <- c("season","team_away","mv_overall_away","mv_average_away","mv_ranking_away")
upcoming_matches <- merge(upcoming_matches,market_values_away)

upcoming_matches <- upcoming_matches[,c(1:19,21,24)]

upcoming_matches$threemonths_performance_home <- as.numeric(upcoming_matches$threemonths_performance_home)
upcoming_matches$threemonths_performance_away <- as.numeric(upcoming_matches$threemonths_performance_away)
upcoming_matches$year_performance_home <- as.numeric(upcoming_matches$year_performance_home)
upcoming_matches$year_performance_away <- as.numeric(upcoming_matches$year_performance_away)
upcoming_matches$threeyear_performance_home <- as.numeric(upcoming_matches$threeyear_performance_home)
upcoming_matches$threeyear_performance_away <- as.numeric(upcoming_matches$threeyear_performance_away)
upcoming_matches <- upcoming_matches[order(upcoming_matches$date),]

upcoming_matches_all <- upcoming_matches
rounds_filter <- round
upcoming_matches <- upcoming_matches_all %>%
  filter(round > rounds_filter)

#Add missing matches
if (length(position_missing_matches)>0) {
for (m in position_missing_matches) {
upcoming_matches <- rbind(upcoming_matches,upcoming_matches_all[m,])  
}  
}

print("data for upcoming matches gathered")

