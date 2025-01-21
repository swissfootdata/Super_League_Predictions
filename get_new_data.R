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

###Scraping Spieldaten

#New data frame
data_transfermarkt_new <- data.frame(9999999,"team_home","team_away",0,0,1,"01.01.1900","99:99","result","result_halftime",99999,"Schiedsrichter",1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,"coach_home","coach_away")
colnames(data_transfermarkt_new) <- c("ID","team_home","team_away","team_home_ranking","team_away_ranking",
                                  "round","date","time","result","result_halftime","crowd","referee",
                                  "shots_overall_home","shots_overall_away","shots_target_home","shots_target_away",
                                  "shots_missed_home","shots_missed_away","shots_hold_home","shots_hold_away",
                                  "corner_home","corner_away","freekicks_home","freekicks_away",
                                  "fouls_home","fouls_away","offside_home","offside_away","coach_home","coach_away")

for (i in games) {
  
  url <- paste0("https://www.transfermarkt.ch/fc-sion_fc-basel-1893/statistik/spielbericht/",i)
  webpage <- read_html(url)
  ID <- i

  team_home <- html_text(html_nodes(webpage,".sb-vereinslink"))[1]
  team_away <- html_text(html_nodes(webpage,".sb-vereinslink"))[2] #3
  team_home_ranking <- which(tabelle_old$team == team_home)
  team_away_ranking <- which(tabelle_old$team == team_away)
 
  spieltag <- parse_number(html_text(html_nodes(webpage,".sb-datum"))[1]) #2
  datum <- gsub( ".*(\\d{2}.\\d{2}.\\d{2}).*", "\\1", html_text(html_nodes(webpage,".sb-datum"))[1]) #2
  datum <- gsub("[.]20",".2020",datum)
  datum <- gsub("[.]21",".2021",datum)
  datum <- gsub("[.]22",".2022",datum)
  datum <- gsub("[.]23",".2023",datum)
  datum <- gsub("[.]24",".2024",datum)
  zeit <- gsub( ".*(\\d{2}:\\d{2}).*", "\\1", html_text(html_nodes(webpage,".sb-datum"))[1]) #2
  
  
  result_fulltime <- gsub("[(].*","",html_text(html_nodes(webpage,".sb-endstand")))[1]
  result_fulltime <- gsub( ".*(\\d{1}:\\d{1}).*", "\\1",result_fulltime)
  
  result_halbzeit <- gsub( ".*(\\d{1}:\\d{1}).*", "\\1", html_text(html_nodes(webpage,".sb-halbzeit")))[1]
  
  zuschauer <- gsub( "[.]", "", html_text(html_nodes(webpage,".sb-zusatzinfos")))
  zuschauer <- as.numeric(gsub("\\D", "", zuschauer))
  
  schiedsrichter <- str_split(html_text(html_nodes(webpage,".sb-zusatzinfos")),"Schiedsrichter:")[[1]][2]
  schiedsrichter <- trimws(gsub("\t","",schiedsrichter))
  
  shots_overall_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[1])
  shots_overall_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[2])
  shots_missed_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[3])
  shots_missed_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[4])
  shots_target_home <- shots_overall_home - shots_missed_home
  shots_target_away <- shots_overall_away - shots_missed_away
  shots_hold_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[5])
  shots_hold_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[6])
  corner_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[7])
  corner_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[8])
  freekicks_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[9])
  freekicks_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[10])
  fouls_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[11])
  fouls_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[12])
  offside_home <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[13])
  offside_away <- as.numeric(html_text(html_nodes(webpage,".sb-statistik-zahl"))[14])
  
  #Coaches
  coach_home <- coaches[coaches$coaches_teams == team_home,1]
  coach_away <- coaches[coaches$coaches_teams == team_away,1]
  
  #Write in dataframe
  new_data <- data.frame(ID,team_home,team_away,team_home_ranking,team_away_ranking,
                         spieltag,datum,zeit,result_fulltime,result_halbzeit,zuschauer,schiedsrichter,
                         shots_overall_home,shots_overall_away,shots_target_home,shots_target_away,
                         shots_missed_home,shots_missed_away,shots_hold_home,shots_hold_away,
                         corner_home,corner_away,freekicks_home,freekicks_away,
                         fouls_home,fouls_away,offside_home,offside_away,coach_home,coach_away)

  
  
  colnames(new_data) <- c("ID","team_home","team_away","team_home_ranking","team_away_ranking",
                          "round","date","time","result","result_halftime","crowd","referee",
                          "shots_overall_home","shots_overall_away","shots_target_home","shots_target_away",
                          "shots_missed_home","shots_missed_away","shots_hold_home","shots_hold_away",
                          "corner_home","corner_away","freekicks_home","freekicks_away",
                          "fouls_home","fouls_away","offside_home","offside_away","coach_home","coach_away")
  
  data_transfermarkt_new <- rbind(data_transfermarkt_new,new_data)
  
  print("scraping completed")
  print(team_home)
  print(nrow(data_transfermarkt_new))
  
  

}


data_transfermarkt_new <- data_transfermarkt_new[-1,]
data_transfermarkt_new$date <- as.Date(data_transfermarkt_new$date,format="%d.%m.%Y")
data_transfermarkt_new$goals_home <- NA
data_transfermarkt_new$goals_away <- NA
data_transfermarkt_new$points_home <- NA
data_transfermarkt_new$points_away <- NA


#Transformations
data_transfermarkt_new$goals_home <- parse_number(gsub(":.*","",data_transfermarkt_new$result))
data_transfermarkt_new$goals_away <- parse_number(gsub(".*:","",data_transfermarkt_new$result))

for (i in 1:nrow(data_transfermarkt_new)) {
  
  if (data_transfermarkt_new$goals_home[i] > data_transfermarkt_new$goals_away[i]) {
    
    data_transfermarkt_new$points_home[i] <- 3
    data_transfermarkt_new$points_away[i] <- 0
    
  } else if (data_transfermarkt_new$goals_home[i] < data_transfermarkt_new$goals_away[i]) {
    
    data_transfermarkt_new$points_home[i] <- 0
    data_transfermarkt_new$points_away[i] <- 3
    
  } else {
    
    data_transfermarkt_new$points_home[i] <- 1
    data_transfermarkt_new$points_away[i] <- 1
    
  }
  
}

#season
data_transfermarkt_new$season <- season

#Liga
data_transfermarkt_new$league <- "Super League"

#Marktwerte
market_values_home <- market_values
colnames(market_values_home) <- c("season","team_home","mv_overall_home","mv_average_home","mv_ranking_home")
data_transfermarkt_new <- merge(data_transfermarkt_new,market_values_home)

market_values_away <- market_values
colnames(market_values_away) <- c("season","team_away","mv_overall_away","mv_average_away","mv_ranking_away")
data_transfermarkt_new <- merge(data_transfermarkt_new,market_values_away)




#ELO-Werte hinzufügen
data_transfermarkt_new$elo_home <- NA
data_transfermarkt_new$elo_away <- NA

for (y in 1:nrow(data_transfermarkt_new)) {
  
  date <- data_transfermarkt_new$date[y]-1
  
  elo_home <- elo_values[elo_values$Club == data_transfermarkt_new$team_home[y],]
  elo_home <- elo_home[elo_home$To <= date,5]
  data_transfermarkt_new$elo_home[y] <- elo_home[length(elo_home)]
  
  
  elo_away <- elo_values[elo_values$Club == data_transfermarkt_new$team_away[y],]
  elo_away <- elo_away[elo_away$To <= date,5]
  data_transfermarkt_new$elo_away[y] <- elo_away[length(elo_away)]
  
  
}

#Form 1 Monat, 3 Monate, 6 Monate, Jahr, insgesamt
data_transfermarkt_new$month_performance_home <- NA
data_transfermarkt_new$month_performance_away <- NA
data_transfermarkt_new$threemonths_performance_home <- NA
data_transfermarkt_new$threemonths_performance_away <- NA
data_transfermarkt_new$sixmonths_performance_home <- NA
data_transfermarkt_new$sixmonths_performance_away <- NA
data_transfermarkt_new$year_performance_home <- NA
data_transfermarkt_new$year_performance_away <- NA
data_transfermarkt_new$threeyear_performance_home <- NA
data_transfermarkt_new$threeyear_performance_away <- NA
data_transfermarkt_new$overall_performance_home <- NA
data_transfermarkt_new$overall_performance_away <- NA
data_transfermarkt_new$same_opponent_home <- NA
data_transfermarkt_new$same_opponent_away <- NA
data_transfermarkt_new$odds_home_win <- NA
data_transfermarkt_new$odds_draw <- NA
data_transfermarkt_new$odds_away_win <- NA

#Merge mit bereits vorhandenen Daten
matches_database <- rbind(matches_database,data_transfermarkt_new) 

#Formdaten hinzufügen
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_home[i]  
  date <- matches_database$date[i]
  last_month <- matches_database[matches_database$date > date-30 & matches_database$date < date & matches_database$team_home == team,]
  performance <- mean(last_month$points_home)
  matches_database$month_performance_home[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_away[i]  
  date <- matches_database$date[i]
  last_month <- matches_database[matches_database$date > date-30 & matches_database$date < date & matches_database$team_away == team,]
  performance <- mean(last_month$points_away)
  matches_database$month_performance_away[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_home[i]  
  date <- matches_database$date[i]
  last_three_months <- matches_database[matches_database$date > date-90 & matches_database$date < date & matches_database$team_home == team,]
  performance <- mean(last_three_months$points_home)
  matches_database$threemonths_performance_home[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_away[i]  
  date <- matches_database$date[i]
  last_three_months <- matches_database[matches_database$date > date-90 & matches_database$date < date & matches_database$team_away == team,]
  performance <- mean(last_three_months$points_away)
  matches_database$threemonths_performance_away[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_home[i]  
  date <- matches_database$date[i]
  last_six_months <- matches_database[matches_database$date > date-180 & matches_database$date < date & matches_database$team_home == team,]
  performance <- mean(last_six_months$points_home)
  matches_database$sixmonths_performance_home[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_away[i]  
  date <- matches_database$date[i]
  last_six_months <- matches_database[matches_database$date > date-180 & matches_database$date < date & matches_database$team_away == team,]
  performance <- mean(last_six_months$points_away)
  matches_database$sixmonths_performance_away[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_home[i]  
  date <- matches_database$date[i]
  last_year <- matches_database[matches_database$date > date-365 & matches_database$date < date & matches_database$team_home == team,]
  performance <- mean(last_year$points_home)
  matches_database$year_performance_home[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_away[i]  
  date <- matches_database$date[i]
  last_year <- matches_database[matches_database$date > date-365 & matches_database$date < date & matches_database$team_away == team,]
  performance <- mean(last_year$points_away)
  matches_database$year_performance_away[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_home[i]  
  date <- matches_database$date[i]
  last_threeyears <- matches_database[matches_database$date > date-1095 & matches_database$date < date & matches_database$team_home == team,]
  performance <- mean(last_threeyears$points_home)
  matches_database$threeyear_performance_home[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_away[i]  
  date <- matches_database$date[i]
  last_threeyears <- matches_database[matches_database$date > date-1095 & matches_database$date < date & matches_database$team_away == team,]
  performance <- mean(last_threeyears$points_away)
  matches_database$threeyear_performance_away[i] <- performance
  
}


for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_home[i]
  date <- matches_database$date[i]
  overall <- matches_database[matches_database$team_home == team & matches_database$date < date,]
  performance <- mean(overall$points_home)
  matches_database$overall_performance_home[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  team <- matches_database$team_away[i]
  date <- matches_database$date[i]
  overall <- matches_database[matches_database$team_away == team & matches_database$date < date,]
  performance <- mean(overall$points_away)
  matches_database$overall_performance_away[i] <- performance
  
}
for (i in (nrow(matches_database)-length(games)):nrow(matches_database)) {
  
  date <- matches_database$date[i]
  team_home <- matches_database$team_home[i]
  team_away <- matches_database$team_away[i] 
  overall <- matches_database[matches_database$team_home == team_home & matches_database$team_away == team_away & matches_database$date < date,]
  performance_home <- mean(overall$points_home)
  performance_away <- mean(overall$points_away)
  matches_database$same_opponent_home[i] <- performance_home
  matches_database$same_opponent_away[i] <- performance_away
}

#Sortieren
matches_database <- matches_database[order(matches_database$date),]

#NA in NULL-Werte
matches_database[is.na(matches_database)] <- "999"

#Select current games
matches_database <- matches_database[matches_database$season == season &
                                       matches_database$round == round,]

matches_database <- matches_database[order(matches_database$team_home),]

#Get odds from Github
odds_matches <- read.csv("https://raw.githubusercontent.com/swissfootdata/Super_League_Predictions/master/Output/predictions_upcoming_matches.csv", encoding = "UTF-8")

if (nrow(matches_database) != 6) {

odds_matches <- odds_matches[1:nrow(matches_database),]  

print("Achtung! Nicht genügend Spiele gefunden für Synchronisation mit Odds. Bitte manuel nachtragen!")
      
}  

#Auf Datenbank zugreifen
mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")

#DE-Datenbank einlesen
sql_qry <- "INSERT IGNORE INTO matches_database(ID,season,league,
team_home,team_away,team_home_ranking,team_away_ranking,
round,date,time,result,result_halftime,crowd,referee,
shots_overall_home,shots_overall_away,shots_target_home,shots_target_away,shots_missed_home,shots_missed_away,shots_hold_home,shots_hold_away,
corner_home,corner_away,freekicks_home,freekicks_away,offside_home,offside_away,fouls_home,fouls_away,
goals_home,goals_away,points_home,points_away,
mv_overall_home,mv_overall_away,mv_average_home,mv_average_away,mv_ranking_home,mv_ranking_away,
elo_home,elo_away,
month_performance_home,month_performance_away,
threemonths_performance_home,threemonths_performance_away,
sixmonths_performance_home,sixmonths_performance_away,
year_performance_home,year_performance_away,
threeyear_performance_home,threeyear_performance_away,
overall_performance_home,overall_performance_away,
same_opponent_home,same_opponent_away,
coach_home,coach_away,
odds_home_win,odds_draw,odds_away_win
) VALUES"

sql_qry <- paste0(sql_qry, paste(sprintf("('%s', '%s', '%s', '%s' , '%s', '%s', '%s', '%s' , '%s', '%s',
                                         '%s', '%s', '%s', '%s' , '%s', '%s', '%s', '%s' , '%s', '%s',
                                         '%s', '%s', '%s', '%s' , '%s', '%s', '%s', '%s' , '%s', '%s',
                                         '%s', '%s', '%s', '%s' , '%s', '%s', '%s', '%s', '%s', '%s',
                                         '%s', '%s', '%s', '%s' , '%s', '%s', '%s', '%s', '%s', '%s',
                                         '%s', '%s','%s', '%s','%s','%s','%s','%s','%s','%s','%s')",
                                         matches_database$ID,
                                         matches_database$season,
                                         matches_database$league,
                                         matches_database$team_home,
                                         matches_database$team_away,
                                         matches_database$team_home_ranking,
                                         matches_database$team_away_ranking,
                                         matches_database$round,
                                         matches_database$date,
                                         matches_database$time,
                                         matches_database$result,
                                         matches_database$result_halftime,
                                         matches_database$crowd,
                                         matches_database$referee,
                                         matches_database$shots_overall_home,
                                         matches_database$shots_overall_away,
                                         matches_database$shots_target_home,
                                         matches_database$shots_target_away,
                                         matches_database$shots_missed_home,
                                         matches_database$shots_missed_away,
                                         matches_database$shots_hold_home,
                                         matches_database$shots_hold_away,
                                         matches_database$corner_home,
                                         matches_database$corner_away,
                                         matches_database$freekicks_home,
                                         matches_database$freekicks_away,
                                         matches_database$offside_home,
                                         matches_database$offside_away,
                                         matches_database$fouls_home,
                                         matches_database$fouls_away,
                                         matches_database$goals_home,
                                         matches_database$goals_away,
                                         matches_database$points_home,
                                         matches_database$points_away,
                                         matches_database$mv_overall_home,
                                         matches_database$mv_overall_away,
                                         matches_database$mv_average_home,
                                         matches_database$mv_average_away,
                                         matches_database$mv_ranking_home,
                                         matches_database$mv_ranking_away,
                                         matches_database$elo_home,
                                         matches_database$elo_away,
                                         matches_database$month_performance_home,
                                         matches_database$month_performance_away,
                                         matches_database$threemonths_performance_home,
                                         matches_database$threemonths_performance_away,
                                         matches_database$sixmonths_performance_home,
                                         matches_database$sixmonths_performance_away,
                                         matches_database$year_performance_home,
                                         matches_database$year_performance_away,
                                         matches_database$threeyear_performance_home,
                                         matches_database$threeyear_performance_away,
                                         matches_database$overall_performance_home,
                                         matches_database$overall_performance_away,
                                         matches_database$same_opponent_home,
                                         matches_database$same_opponent_away,
                                         matches_database$coach_home,
                                         matches_database$coach_away,
                                         odds_matches$win.home.team,
                                         odds_matches$draw,
                                         odds_matches$win.away.team
), collapse = ","))
dbGetQuery(mydb, "SET NAMES 'utf8'")
rs <- dbSendQuery(mydb, sql_qry)

#Datenbankverbindungen schliessen
dbDisconnectAll()

print("New data written in Database")
