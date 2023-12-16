#Set working directory
#setwd("C:/Users/Administrator/Desktop/predictions")
setwd("C:/Users/simon/OneDrive/Fussballdaten/Super_League_Predictions")

#Load library
source("config.R")

#Season
season <- "23/24"

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
#games <- c(4089787)
#round <- 16
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
source("predict_season.R", encoding= "UTF-8")

#Predict coaches
source("predict_coaches.R", encoding= "UTF-8")

#Store played rounds
cat(round,file="rounds_played.txt")

#Make Commit
source("commit.R", encoding = "UTF-8")

