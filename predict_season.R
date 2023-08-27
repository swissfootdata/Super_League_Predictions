#How many iterations
iterations <- 10000

#Get scores so far
current_season <- data_transfermarkt[data_transfermarkt$season == season,]
current_season <- current_season[!is.na(current_season$points_home),]

scores_home <- aggregate(current_season$points_home,by=list(current_season$team_home),FUN=sum)
scores_away <- aggregate(current_season$points_away,by=list(current_season$team_away),FUN=sum)

#Add scores so far
scores_season <- merge(scores_home,scores_away,by="Group.1")
scores_season$score <- scores_season$x.x + scores_season$x.y

###Create Data Frame to collect all iterations
season_prognosis <- data.frame(0,0,0,0,0,0,0,0,0,0,0,0)
colnames(season_prognosis) <- c("BSC Young Boys","FC Basel 1893","FC Lausanne-Sport","FC Lugano","FC Luzern","FC St. Gallen 1879","FC Stade-Lausanne-Ouchy","FC Winterthur","FC Zürich","Grasshopper Club Zürich","Servette FC","Yverdon Sport FC")

#Remove rankings
X_season <- X[,-c(1:2)]

# Train the model 
regr <- randomForest(x = X_season, y = y , maxnodes = 250, ntree = 1100)
print(regr)


###Start learning process
for (a in 1:iterations) {

#Get needed data from upcoming matches
new_games <- upcoming_matches_all[,c(2:3,12:21)]

  ##Adapt schedule
  #Switch home and away every 2nd iteration
  if (a %% 2 == 0) {
  second_half <- new_games[67:132,]
  new_games <- rbind(new_games,second_half)
  
  #Pick random sample
  last_rounds <- sample(seq(1,66,6),5)
  for (l in last_rounds) {
  selected_matches <- new_games[l:(l+5),]
  new_games <- rbind(new_games,selected_matches)
  }

  } else {
  second_half <- new_games[1:66,]
  new_games <- rbind(new_games,second_half)
  
  #Pick random sample
  last_rounds <- sample(seq(67,132,6),5)
  for (l in last_rounds) {
  selected_matches <- new_games[l:(l+5),]
  new_games <- rbind(new_games,selected_matches)
  }
  }  

#Shift missing matches
if (length(position_missing_matches)>0) {
  for (m in position_missing_matches) {
    new_games <- rbind(new_games,new_games[m,])
  }
  new_games <- new_games[-c(position_missing_matches),]
}

  #Remove already played matches
  new_games <- new_games[-c(1:(nrow(upcoming_matches_all)-nrow(upcoming_matches))),]

  #Predict next games
  prediction_next_game <- predict(regr, new_games, type="prob")
  
  #Get score for home and away team
  prediction_next_game <- cbind(prediction_next_game,as.character(new_games$team_home),as.character(new_games$team_away))
  prediction_next_game <- as.data.frame(prediction_next_game)

  prediction_next_game$score_home <- 0
  prediction_next_game$score_away <- 0
  for (p in 1:nrow(prediction_next_game)) {
    prediction_next_game$score_home[p] <- sample(c(3,1,0),prob=c(as.numeric(prediction_next_game$`win home`[p]),as.numeric(prediction_next_game$`draw`[p]),as.numeric(prediction_next_game$`win away`[p])), size=1)
    
    if (prediction_next_game$score_home[p] == 3) {
      prediction_next_game$score_away[p] <- 0
    } else if (prediction_next_game$score_home[p] == 0) {
      prediction_next_game$score_away[p] <- 3
    } else {
      prediction_next_game$score_away[p] <- 1
    }
  }   
  #Get overall score of all teams
  scores_home <- aggregate(prediction_next_game$score_home,by=list(prediction_next_game$V4),FUN=sum)
  scores_away <- aggregate(prediction_next_game$score_away,by=list(prediction_next_game$V5),FUN=sum)

  scores_new <- merge(scores_home,scores_away,by="Group.1")
  scores_new$score <- scores_new$x.x + scores_new$x.y

  #Merge to final score by adding scores so far
  scores_overall <- merge(scores_new,scores_season,by="Group.1")
  scores_overall$final_score <- scores_overall$score.x + scores_overall$score.y
  #scores_overall <- scores_new
  #scores_overall$final_score <- scores_new$score
  
  #Write final score in new data frame
  season_prognosis <- rbind(season_prognosis,scores_overall$final_score)
  print("new entry done")
  print(nrow(season_prognosis))
  print(scores_overall$final_score)
}

season_prognosis <- season_prognosis[-1,]

#Create table
table <- as.data.frame(round(colMeans(season_prognosis))) 
table$teams <- row.names(table)

#Get last predictions
last_prediction <- read.csv("https://raw.githubusercontent.com/swissfootdata/Super_League_Predictions/master/Output/predictions_season.csv", encoding = "UTF-8")
last_prediction <- last_prediction[,1:2]

table_new <- merge(table,last_prediction,by.x="teams",by.y="Team")
table_new$change <- table_new$`round(colMeans(season_prognosis))`-table_new$Final.Score

colnames(table_new) <- c("Team","Final Score","Last Prediction","Change")
table_new <- table_new[order(-table_new$`Final Score`),]

write.csv(table_new,file="Output/predictions_season.csv", row.names=FALSE, fileEncoding = "UTF-8")

print(table_new)
#Get data for prediction
data_home <- new_games %>% distinct(team_home,.keep_all = TRUE)
data_home <- data_home[,c(2,3,5,7,9,11)]

data_away <- new_games %>% distinct(team_away,.keep_all = TRUE)
data_away <- data_away[,c(1,4,6,8,10,12)]

data_table <- merge(data_home,data_away,by.x="team_home",by.y="team_away")
data_table <- data_table[,c(1,5,6,2,7,3,8,4,9)]

colnames(data_table) <- c("Team","Elo value","average market value per player",
                          "average score last three months home","average score last three months away",
                          "average score last year home","average score last year away",
                          "average score last three years home","average score last three years away")


data_table <- data_table[order(data_table$Team),]
write.csv(data_table,file="Output/predictions_season_data.csv", row.names=FALSE, fileEncoding = "UTF-8")

#Prediction development
trend_prediction <- table_new[order(table_new$Team),c(1:2)]
trend_prediction$Team <- gsub(" ","_",trend_prediction$Team)

new_entry_prediction <- as.data.frame(spread(trend_prediction,"Team","Final Score"))
new_entry_prediction$date <- Sys.Date()

#Load Data from the past
old_data_predictions <- read.csv("https://raw.githubusercontent.com/swissfootdata/Super_League_Predictions/master/Output/trend_predictions.csv",encoding = "UTF-8")
colnames(old_data_predictions)[3] <- "FC_Lausanne-Sport"
colnames(old_data_predictions)[7] <- "FC_Stade-Lausanne-Ouchy"
old_data_predictions$date <- as.Date(old_data_predictions$date)

#Add Data
trend_prediction <- rbind(old_data_predictions,new_entry_prediction)
trend_prediction$date <- as.Date(trend_prediction$date)

write.csv(unique(trend_prediction),file="Output/trend_predictions.csv", row.names=FALSE, fileEncoding = "UTF-8")

#Rankings probabilities
data_rankings <- as.data.frame(t(apply(-season_prognosis, 1, rank, ties.method='random')))

table_rankings <- data.frame("team",0,0,0,0,0,0,0,0,0,0,0,0)
colnames(table_rankings) <- c("team","champion","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth","eleventh","twelfth")

for (t in 1:ncol(data_rankings)) {

new_data <- data.frame(colnames(data_rankings)[t],
                       length(which(data_rankings[,t] == 1))/(iterations/100),
                       length(which(data_rankings[,t] == 2))/(iterations/100),
                       length(which(data_rankings[,t] == 3))/(iterations/100),
                       length(which(data_rankings[,t] == 4))/(iterations/100),
                       length(which(data_rankings[,t] == 5))/(iterations/100),
                       length(which(data_rankings[,t] == 6))/(iterations/100),
                       length(which(data_rankings[,t] == 7))/(iterations/100),
                       length(which(data_rankings[,t] == 8))/(iterations/100),
                       length(which(data_rankings[,t] == 9))/(iterations/100),
                       length(which(data_rankings[,t] == 10))/(iterations/100),
                       length(which(data_rankings[,t] == 11))/(iterations/100),
                       length(which(data_rankings[,t] == 12))/(iterations/100)
                       )

colnames(new_data) <- c("team","champion","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth","eleventh","twelfth")
table_rankings <- rbind(table_rankings,new_data)
}

table_rankings <- table_rankings[-1,]
table_rankings <- table_rankings %>%
  arrange(desc(champion),desc(second),desc(third),desc(fourth),desc(fifth))

colnames(table_rankings) <- c("Team","1st","2nd","3rd","4th","5th","6th",
                              "7th","8th","9th","10th","11th","12th")
write.csv(table_rankings,file="Output/probabilities_predictions.csv", row.names=FALSE, fileEncoding = "UTF-8")

print(table_rankings)



