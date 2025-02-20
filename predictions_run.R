#Set working directory
#setwd("C:/Users/Administrator/Desktop/predictions")
setwd("C:/Users/simon/OneDrive/Fussballdaten/Super_League_Predictions")

#Load library
source("config.R")

#Season
season <- "24/25"

#Get Elo-Daten
source("get_elodata.R", encoding = "UTF-8")

#Marktwerte laden
source("get_market_values.R", encoding = "UTF-8")

#Coaches laden
source("get_coaches.R", encoding = "UTF-8")

#Tabelle Laden
source("get_table.R", encoding="UTF-8")

#Get Recently played matches and upcoming matches
source("getting_ids.R", encoding = "UTF-8")

rounds_played <- as.numeric(read.delim("rounds_played.txt", header=FALSE))

#Adaptions
#games <- c(4514293:4514298)
#round <- 23
missing_matches <- c()
position_missing_matches <- c()
#new_matches[(length(new_matches)+1):(length(new_matches)+length(missing_matches))] <- missing_matches

#Scrape recently played matches
source("get_new_data.R", encoding = "UTF-8")

#Scrape upcoming matches
source("get_upcoming_matches.R", encoding = "UTF-8")

#Predict next round
source("predict_next_round.R", encoding= "UTF-8")

#Predict season
source("predict_season_after_winter.R", encoding= "UTF-8")

#Predict coaches
source("predict_coaches.R", encoding= "UTF-8")

#Store played rounds
cat(round,file="rounds_played.txt")

#Make Commit
source("commit.R", encoding = "UTF-8")

 #Apdaptations
# upcoming_matches_all[132,] <- upcoming_matches_all[41,]
# upcoming_matches_all$team_away[132] <- upcoming_matches_all$team_away[40]
# upcoming_matches_all$team_away_ranking[132] <- upcoming_matches_all$team_away_ranking[40]
# upcoming_matches_all$threemonths_performance_away[132] <- upcoming_matches_all$threemonths_performance_away[40]
# upcoming_matches_all$year_performance_away[132] <- upcoming_matches_all$year_performance_away[40]
# upcoming_matches_all$threeyear_performance_away[132] <- upcoming_matches_all$threeyear_performance_away[40]
# upcoming_matches_all$elo_away[132] <- upcoming_matches_all$elo_away[40]
# upcoming_matches_all$mv_average_away[132] <-upcoming_matches_all$mv_average_away[40]
# upcoming_matches_all$round[132] <- 5
# 
# upcoming_matches[108,] <- upcoming_matches[17,]
# upcoming_matches$team_away[108] <- upcoming_matches$team_away[16]
# upcoming_matches$team_away_ranking[108] <- upcoming_matches$team_away_ranking[16]
# upcoming_matches$threemonths_performance_away[108] <- upcoming_matches$threemonths_performance_away[16]
# upcoming_matches$year_performance_away[108] <- upcoming_matches$year_performance_away[16]
# upcoming_matches$threeyear_performance_away[108] <- upcoming_matches$threeyear_performance_away[16]
# upcoming_matches$elo_away[108] <- upcoming_matches$elo_away[16]
# upcoming_matches$mv_average_away[108] <-upcoming_matches$mv_average_away[16]
# upcoming_matches$round[108] <- 5
