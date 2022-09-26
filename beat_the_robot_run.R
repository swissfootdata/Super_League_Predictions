#Get Tips
tips <- read_csv(tips_path)

#Eliminate double entries
tips <- tips %>%
  distinct(`E-Mail-Adresse`, .keep_all=TRUE)

#Evaluate score of the robot
compare <- merge(last_results,predictions_robot_old)
score_robot <- sum(compare$target == compare$Prediction)

#Evaluate scores of the players
tips$score <- 0
tips$won <- 0
tips$lost <- 0
tips$tie <- 0



for (i in 1:nrow(tips)) {
  
 if (as.character(tips[i,2]) == as.character(last_results[1,2])) {
   
  tips$score[i] <- tips$score[i] + 1 
 }

  if (as.character(tips[i,3]) == as.character(last_results[2,2])) {
    
    tips$score[i] <- tips$score[i] + 1 
  }
  
  if (as.character(tips[i,6]) == as.character(last_results[3,2])) {
    
    tips$score[i] <- tips$score[i] + 1 
  }
  
  if (as.character(tips[i,7]) == as.character(last_results[4,2])) {
    
   tips$score[i] <- tips$score[i] + 1 
  }

  if (as.character(tips[i,8]) == as.character(last_results[5,2])) {
    
    tips$score[i] <- tips$score[i] + 1 
  }


  if (tips$score[i] > score_robot) {
    
    
    tips$won[i] <- tips$won[i] + 1
    
  } else if (tips$score[i] == score_robot) {
    
    
    tips$tie[i] <- tips$tie[i] + 1 
    
  } else {
    
    tips$lost[i] <- tips$lost[i] + 1
    
  }
    
}  

tips$fail <- nrow(last_results)-tips$score

print(paste0(nrow(tips)," tips detected"))
print(tips)

#Save data of round
save(tips,file=paste0("BeatTheRobot/tips_",round,".Rda"))

#Create "Hallo of Fame" with all winners
hall_of_fame <- data.frame(tips[tips$won == 1,c(4,9:10)])
colnames(hall_of_fame) <- c("Player","Twitter account","correct guesses")

if (nrow(hall_of_fame) == 0) {

hall_of_fame <- data.frame("Nobody beat SwissFootyBot!",NA,NA)
colnames(hall_of_fame) <- c("Player","Twitter account","correct guesses")

}

hall_of_fame <- hall_of_fame[order(-hall_of_fame$`correct guesses`,hall_of_fame$Player),]

write.csv(hall_of_fame,file="Output/HallOfFame_BeatTheRobot.csv",row.names = FALSE, fileEncoding = "UTF-8")
print(paste0("Hall of Fame: ",nrow(hall_of_fame)," players outsmarted SwissFootyBot"))
print(hall_of_fame)

#Performance of SwissFootyBot
accuracy_robot <- score_robot/nrow(last_results)
ties_robot <- sum(tips$tie)
wins_robot <- sum(tips$lost)
losses_robot <- sum(tips$won)

#Load new data in database
mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")

#Load new data
sql_qry <- "INSERT IGNORE INTO performance_btr(round,score,accuracy,wins,losses,ties) VALUES"

sql_qry <- paste0(sql_qry, paste(sprintf("('%s', '%s', '%s', '%s' , '%s', '%s')",
                                         round,
                                         score_robot,
                                         accuracy_robot,
                                         wins_robot,
                                         losses_robot,
                                         ties_robot
                                         
), collapse = ","))

dbGetQuery(mydb, "SET NAMES 'utf8'")
rs <- dbSendQuery(mydb, sql_qry)

#Get all data Performance Robot
mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")
dbGetQuery(mydb, "SET NAMES 'utf8'")

rs <- dbSendQuery(mydb, "SELECT * FROM performance_btr")
performance_robot <- fetch(rs,n=-1, encoding="utf8")

performance_robot <- performance_robot[order(-performance_robot$round),]
performance_robot$round <- as.character(performance_robot$round)

round_overall <- "all"
score_overall <- sum(performance_robot$score)
accuracy_overall <- mean(performance_robot$accuracy)
wins_overall <- sum(performance_robot$wins)
losses_overall <- sum(performance_robot$losses)
ties_overall <- sum(performance_robot$ties)

performance_robot <- performance_robot %>%
  add_row(round=round_overall,score=score_overall,accuracy=accuracy_overall,wins=wins_overall,losses=losses_overall,ties=ties_overall,.before=TRUE)

write.csv(performance_robot,file="Output/Performance_BeatTheRobot.csv",row.names = FALSE, fileEncoding = "UTF-8")

#Get current Leaderboard

mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")
dbGetQuery(mydb, "SET NAMES 'utf8'")

rs <- dbSendQuery(mydb, "SELECT * FROM leaderboard_btr")
leaderboard <- fetch(rs,n=-1, encoding="utf8")
Encoding(leaderboard$email) <- "UTF-8"
Encoding(leaderboard$name) <- "UTF-8"
Encoding(leaderboard$twitter) <- "UTF-8"


#Save old data (to be sure)
save(leaderboard,file=paste0("BeatTheRobot/leaderboard_",round,".Rda"))


#Merge with new data and adapt

tips$round_played <- 1
tips$`E-Mail-Adresse` <- tolower(tips$`E-Mail-Adresse`)
leaderboard$email <- tolower(leaderboard$email)

leaderboard_new <- merge(leaderboard,tips,by.x="email",by.y="E-Mail-Adresse",all=TRUE)


for (i in 1:nrow(leaderboard_new)) {
  
 if (is.na(leaderboard_new$`Your Twitter account (optional)`[i])==TRUE) {
   
   
  leaderboard_new$`Your Twitter account (optional)`[i] <- leaderboard_new$twitter[i]
 }
  
  if (is.na(leaderboard_new$`Your full name`[i])==TRUE) {
    
    
    leaderboard_new$`Your full name`[i] <- leaderboard_new$name[i]
  }
  
  
  
}


leaderboard_new[is.na(leaderboard_new)] <- 0

leaderboard_new$wins <- leaderboard_new$wins + leaderboard_new$won
leaderboard_new$losses <- leaderboard_new$losses + leaderboard_new$lost
leaderboard_new$ties <- leaderboard_new$ties + leaderboard_new$tie
leaderboard_new$correct_guesses <- leaderboard_new$correct_guesses + leaderboard_new$score
leaderboard_new$wrong_guesses <- leaderboard_new$wrong_guesses + leaderboard_new$fail
leaderboard_new$accuracy <- leaderboard_new$correct_guesses/(leaderboard_new$correct_guesses+leaderboard_new$wrong_guesses)
leaderboard_new$rounds_played <- leaderboard_new$rounds_played + leaderboard_new$round_played

#Select Data
leaderboard_new <- leaderboard_new[,c(1,14,18,4:10)]

#Load new data in database
mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")

#Empty current database
sql_qry <- "TRUNCATE TABLE football_data.leaderboard_btr"
rs <- dbSendQuery(mydb, sql_qry)


#Load new data
sql_qry <- "INSERT INTO leaderboard_btr(email,name,twitter,wins,losses,ties,correct_guesses,wrong_guesses,accuracy,rounds_played) VALUES"

sql_qry <- paste0(sql_qry, paste(sprintf("('%s', '%s', '%s', '%s' , '%s', '%s', '%s', '%s' , '%s', '%s')",
                                         leaderboard_new$email,
                                         leaderboard_new$`Your full name`,
                                         leaderboard_new$`Your Twitter account (optional)`,
                                         leaderboard_new$wins,
                                         leaderboard_new$losses,
                                         leaderboard_new$ties,
                                         leaderboard_new$correct_guesses,
                                         leaderboard_new$wrong_guesses,
                                         leaderboard_new$accuracy,
                                         leaderboard_new$rounds_played
                                       
), collapse = ","))

dbGetQuery(mydb, "SET NAMES 'utf8'")
rs <- dbSendQuery(mydb, sql_qry)

dbDisconnectAll()

#Save leaderboard as csv for Datawrapper
leaderboard_dw <- leaderboard_new[,c(2:10)]
leaderboard_dw <- leaderboard_dw[order(-leaderboard_dw$wins,-leaderboard_dw$accuracy),]
leaderboard_dw$`Your Twitter account (optional)`[leaderboard_dw$`Your Twitter account (optional)`== 0] <- "No account"

write.csv(leaderboard_dw,file="Output/Leaderboard_BeatTheRobot.csv",row.names = FALSE, fileEncoding = "UTF-8")

print(leaderboard_dw)

