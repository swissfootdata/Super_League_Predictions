#Load guesses and adapt
guesses_players <- read_excel("BeatTheRobot_3/Beat the Robot 3.0 (Antworten).xlsx")

for (c in 5:ncol(guesses_players)) {
  
guesses_players[,c] <- guesses_players[,c]/36  
  
}

#Tabelle sortieren
tabelle <- tabelle %>%
  arrange(team)

###Neues Dataframe mit Spielstand
ranking <- data.frame("Simon Wolanin",0,"no",
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0,
                      0,0,0)

colnames(ranking) <- c("Name","Ø difference","robot beaten?",
                       "Ø score FCZ","guess FCZ","difference FCZ",
                       "Ø score Basel","guess Basel","difference Basel",
                       "Ø score YB","guess YB","difference YB",
                       "Ø score Lugano","guess Lugano","difference Lugano",
                       "Ø score FCSG","guess FCSG","difference FCSG",
                       "Ø score Servette","guess Servette","difference Servette",
                       "Ø score Sion","guess Sion","difference Sion",
                       "Ø score GC","guess GC","difference GC",
                       "Ø score FCL","guess FCL","difference FCL",
                       "Ø score Winti","guess Winti","difference Winti"
                       )

#Daten ausrechnen
for (r in 1:nrow(guesses_players)) {
  

name <- guesses_players[r,3]

score_fcz <-tabelle$score[8]/tabelle$matches[8]
guess_fcz <- guesses_players[r,5]
difference_fcz <- abs(score_fcz-guess_fcz)

score_fcb <- tabelle$score[2]/tabelle$matches[2]
guess_fcb <- guesses_players[r,6]
difference_fcb <- abs(score_fcb-guess_fcb)

score_yb <- tabelle$score[1]/tabelle$matches[1]
guess_yb <- guesses_players[r,7]
difference_yb <- abs(score_yb-guess_yb)

score_lugano <- tabelle$score[3]/tabelle$matches[3]
guess_lugano <- guesses_players[r,8]
difference_lugano <- abs(score_lugano-guess_lugano)

score_fcsg <-  tabelle$score[6]/tabelle$matches[6]
guess_fcsg <- guesses_players[r,9]
difference_fcsg <- abs(score_fcsg-guess_fcsg)

score_servette <- tabelle$score[10]/tabelle$matches[10]
guess_servette <- guesses_players[r,10]
difference_servette <- abs(score_servette-guess_servette)

score_sion <- tabelle$score[5]/tabelle$matches[5]
guess_sion <- guesses_players[r,11]
difference_sion <- abs(score_sion-guess_sion)

score_gc <- tabelle$score[9]/tabelle$matches[9]
guess_gc <- guesses_players[r,12]
difference_gc <- abs(score_gc-guess_gc)

score_fcl <- tabelle$score[4]/tabelle$matches[4]
guess_fcl <- guesses_players[r,13]
difference_fcl <- abs(score_fcl-guess_fcl)

score_winti <- tabelle$score[7]/tabelle$matches[7]
guess_winti <- guesses_players[r,14]
difference_winti <- abs(score_winti-guess_winti)

average_difference <- mean(c(difference_fcb[,1],difference_winti[,1],difference_gc[,1],difference_fcz[,1],difference_fcsg[,1],
                           difference_lugano[,1],difference_fcl[,1],difference_sion[,1],difference_yb[,1],difference_servette[,1]))


new_data <- data.frame(name[,1],average_difference,NA,
                       score_fcz,guess_fcz[,1],difference_fcz[,1],
                       score_fcb,guess_fcb[,1],difference_fcb[,1],
                       score_yb,guess_yb[,1],difference_yb[,1],
                       score_lugano,guess_lugano[,1],difference_lugano[,1],
                       score_fcsg,guess_fcsg[,1],difference_fcsg[,1],
                       score_servette,guess_servette[,1],difference_servette[,1],
                       score_sion,guess_sion[,1],difference_sion[,1],
                       score_gc,guess_gc[,1],difference_gc[,1],
                       score_fcl,guess_fcl[,1],difference_fcl[,1],
                       score_winti,guess_winti[,1],difference_winti[,1]
                       )
colnames(new_data) <-  c("Name","Ø difference","robot beaten?",
                         "Ø score FCZ","guess FCZ","difference FCZ",
                         "Ø score Basel","guess Basel","difference Basel",
                         "Ø score YB","guess YB","difference YB",
                         "Ø score Lugano","guess Lugano","difference Lugano",
                         "Ø score FCSG","guess FCSG","difference FCSG",
                         "Ø score Servette","guess Servette","difference Servette",
                         "Ø score Sion","guess Sion","difference Sion",
                         "Ø score GC","guess GC","difference GC",
                         "Ø score FCL","guess FCL","difference FCL",
                         "Ø score Winti","guess Winti","difference Winti"
                                             
)

ranking <- rbind(ranking,new_data)

}

ranking <- ranking[-1,]

#Check if robot is beaten
scores_robot <- ranking[1,]
score_robot <- ranking$`Ø difference`[1]
ranking$`robot beaten?` <- ranking$`Ø difference` < score_robot

ranking$`robot beaten?` <- gsub(TRUE,"&#x2714;&#xFE0F;",ranking$`robot beaten?`)
ranking$`robot beaten?` <- gsub(FALSE,"&#x274C;",ranking$`robot beaten?`)


ranking <- ranking[-1,]

ranking <- ranking[order(ranking$`Ø difference`),]

write.csv(ranking,file="Output/ranking_beattherobot_3.csv",row.names = FALSE, fileEncoding = "UTF-8")

print(head(ranking))

#Overview

overview <- data.frame("team",0,0,0,0,0)
colnames(overview) <- c("team","average score","Ø prediction players","difference players","prediction robot","difference robot")

for (a in seq(4,33,3)) {
  
new_entry <- data.frame(NA,ranking[1,a],mean(ranking[,a+1]),mean(ranking[,a+2]),scores_robot[a+1],scores_robot[a+2])
colnames(new_entry) <- c("team","average score","Ø prediction players","difference players","prediction robot","difference robot")

overview <- rbind(overview,new_entry)

}  

overview <- overview[-1,]

#Overall
new_entry <- data.frame(NA,NA,NA,mean(overview$`difference players`),NA,mean(overview$`difference robot`))
colnames(new_entry) <- c("team","average score","Ø prediction players","difference players","prediction robot","difference robot")

overview <- rbind(overview,new_entry)

overview$team <- c("FCZ","Basel","YB","Lugano","FCSG","Servette","Sion","GC","FCL","Winti","Ø difference")

write.csv(overview,file="Output/overview_beattherobot_3.csv",row.names = FALSE, fileEncoding = "UTF-8")

print(overview)
