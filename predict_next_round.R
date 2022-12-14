#Auf Datenbank zugreifen
mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")
dbGetQuery(mydb, "SET NAMES 'utf8'")

rs <- dbSendQuery(mydb, "SELECT * FROM matches_database")
data_transfermarkt <- fetch(rs,n=-1, encoding="utf8")
Encoding(data_transfermarkt$team_home) <- "UTF-8"
Encoding(data_transfermarkt$team_away) <- "UTF-8"
Encoding(data_transfermarkt$referee) <- "UTF-8"
Encoding(data_transfermarkt$coach_home) <- "UTF-8"
Encoding(data_transfermarkt$coach_away) <- "UTF-8"

dbDisconnectAll()

data_transfermarkt$date <- as.Date(data_transfermarkt$date)


#999 als NA
data_transfermarkt[data_transfermarkt == 999] <- NA

#Target variable
data_transfermarkt$target <- data_transfermarkt$points_home
data_transfermarkt$target <- gsub(3,"win home",data_transfermarkt$target)
data_transfermarkt$target <- gsub(1,"draw",data_transfermarkt$target)
data_transfermarkt$target <- gsub(0,"win away",data_transfermarkt$target)
data_transfermarkt$target <- as.factor(data_transfermarkt$target)


#Last results
#last_results <- data_transfermarkt[data_transfermarkt$season == season & data_transfermarkt$round == as.numeric(round),c(4:5,ncol(data_transfermarkt))]
#last_results$match <- paste0(last_results$team_home,"-",last_results$team_away)
#last_results <- last_results[,c(4,3)]
#last_results <- last_results[order(last_results$match),]

#Select data
data_rf <- data_transfermarkt %>%
  select(team_home_ranking,team_away_ranking,
         mv_average_home,mv_average_away,
         elo_home,elo_away,
         threemonths_performance_home,threemonths_performance_away,
         year_performance_home,year_performance_away,
         threeyear_performance_home,threeyear_performance_away,
         target)

data_rf <- na.omit(data_rf)

X <- data_rf[,1:ncol(data_rf)-1]
y <- data_rf$target

predictions_next_game <- data.frame("bla",999,999,999)
colnames(predictions_next_game) <- c("match","win home team","draw","win away team")

#New games
next_round <- upcoming_matches[upcoming_matches$round == as.numeric(round)+1,]
matches <- paste0(next_round$team_home,"-",next_round$team_away)
new_games <- next_round[,c(4:5,12:21)]


for (i in 1:100) {
  
# Train the model 
regr <- randomForest(x = X, y = y, maxnodes = 250, ntree = 1100, type="prob")

#Predict next games
prediction_next_game <- predict(regr, new_games, type="prob")

prediction_next_game <- cbind(prediction_next_game,matches)
prediction_next_game <- prediction_next_game[,c(4,3,1,2)]
colnames(prediction_next_game) <- c("match","win home team","draw","win away team")

predictions_next_game <- rbind(predictions_next_game,prediction_next_game)

print(i)
print(prediction_next_game)

}

predictions_next_game <- predictions_next_game[-1,]
predictions_next_game$`win home team` <- as.numeric(predictions_next_game$`win home team`)
predictions_next_game$draw <- as.numeric(predictions_next_game$draw)
predictions_next_game$`win away team` <- as.numeric(predictions_next_game$`win away team`)

predictions_next_game <- predictions_next_game  %>%
  group_by(match) %>% 
  summarise_each(funs(mean))

write.csv(predictions_next_game,file="Output/predictions_upcoming_matches.csv",row.names = FALSE, fileEncoding = "UTF-8")

print(predictions_next_game)

#Predictions for Beat the Robot
predictions_next_game$`Prediction` <- NA

for (i in 1:nrow(predictions_next_game)) {
  
  if ( (predictions_next_game$`win home team`[i] > predictions_next_game$draw[i]) & (predictions_next_game$`win home team`[i] > predictions_next_game$`win away team`[i]) ) {

  predictions_next_game$Prediction[i] <- "win home"
  
  } else if (( (predictions_next_game$`win away team`[i] > predictions_next_game$draw[i]) & (predictions_next_game$`win away team`[i] > predictions_next_game$`win home team`[i]) )) { 
  
    predictions_next_game$Prediction[i] <- "win away"
    
    } else {
      
    predictions_next_game$Prediction[i] <- "draw"
    
    }  
  
}

predictions_robot <- predictions_next_game[,c(1,5)]
print(predictions_robot)

write.csv(predictions_robot,file="Output/predictions_SwissFootyBot.csv",row.names = FALSE, fileEncoding = "UTF-8")
