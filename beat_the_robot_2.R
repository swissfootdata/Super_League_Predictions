#Load guesses and adapt
guesses_players <- read_excel("BeatTheRobot_2/Beat the Robot 2.0 (Antworten).xlsx")

for (c in 5:ncol(guesses_players)) {
  
guesses_players[,c] <- guesses_players[,c]/36  
  
}


#Tabellendaten laden
url <- "https://www.transfermarkt.ch/super-league/spieltagtabelle/wettbewerb/C1/saison_id/2021"
webpage <- read_html(url)


data_tabelle <- html_text(html_nodes(webpage,"td"))

tabelle <- data.frame("team",0,0)
colnames(tabelle) <- c("team","matches","score")


for (i in seq(75,168,10)) {
 
team <- data_tabelle[i]
matches <- data_tabelle[i+1]
score <- data_tabelle[i+7]
  
new_data <- data.frame(team,matches,score)
colnames(new_data) <- c("team","matches","score")
tabelle <- rbind(tabelle,new_data)
  
}  

tabelle <- tabelle[-1,]
tabelle <- tabelle[order(tabelle$team),]

tabelle$matches <- as.numeric(gsub("-",0,tabelle$matches))
tabelle$score <- as.numeric(gsub("-",0,tabelle$score))

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
  "Ø score YB","guess YB","difference YB",
  "Ø score Basel","guess Basel","difference Basel",
  "Ø score Lugano","guess Lugano","difference Lugano",
  "Ø score FCL","guess FCL","difference FCL",
  "Ø score Sion","guess Sion","difference Sion",
  "Ø score FCSG","guess FCSG","difference FCSG",
  "Ø score FCZ","guess FCZ","difference FCZ",
  "Ø score GC","guess GC","difference GC",
  "Ø score Lausanne","guess Lausanne","difference Lausanne",
  "Ø score Servette","guess Servette","difference Servette"
  )

#Daten ausrechnen
for (r in 1:nrow(guesses_players)) {
  

name <- guesses_players[r,3]

score_yb <- tabelle$score[1]/tabelle$matches[1]
guess_yb <- guesses_players[r,5]
difference_yb <- abs(score_yb-guess_yb)

score_fcb <- tabelle$score[2]/tabelle$matches[2]
guess_fcb <- guesses_players[r,6]
difference_fcb <- abs(score_fcb-guess_fcb)

score_lugano <- tabelle$score[3]/tabelle$matches[3]
guess_lugano <- guesses_players[r,11]
difference_lugano <- abs(score_lugano-guess_lugano)

score_fcl <- tabelle$score[4]/tabelle$matches[4]
guess_fcl <- guesses_players[r,10]
difference_fcl <- abs(score_fcl-guess_fcl)

score_sion <- tabelle$score[5]/tabelle$matches[5]
guess_sion <- guesses_players[r,12]
difference_sion <- abs(score_sion-guess_sion)

score_fcsg <-  tabelle$score[6]/tabelle$matches[6]
guess_fcsg <- guesses_players[r,13]
difference_fcsg <- abs(score_fcsg-guess_fcsg)

score_fcz <-tabelle$score[7]/tabelle$matches[7]
guess_fcz <- guesses_players[r,8]
difference_fcz <- abs(score_fcz-guess_fcz)

score_gc <- tabelle$score[8]/tabelle$matches[8]
guess_gc <- guesses_players[r,14]
difference_gc <- abs(score_gc-guess_gc)

score_lausanne <- tabelle$score[9]/tabelle$matches[9]
guess_lausanne <- guesses_players[r,7]
difference_lausanne <- abs(score_lausanne-guess_lausanne)

score_servette <- tabelle$score[10]/tabelle$matches[10]
guess_servette <- guesses_players[r,9]
difference_servette <- abs(score_servette-guess_servette)

average_difference <- mean(c(difference_fcb[,1],difference_lausanne[,1],difference_gc[,1],difference_fcz[,1],difference_fcsg[,1],
                           difference_lugano[,1],difference_fcl[,1],difference_sion[,1],difference_yb[,1],difference_servette[,1]))


new_data <- data.frame(name[,1],average_difference,NA,
                       score_yb,guess_yb[,1],difference_yb[,1],
                       score_fcb,guess_fcb[,1],difference_fcb[,1],
                       score_lugano,guess_lugano[,1],difference_lugano[,1],
                       score_fcl,guess_fcl[,1],difference_fcl[,1],
                       score_sion,guess_sion[,1],difference_sion[,1],
                       score_fcsg,guess_fcsg[,1],difference_fcsg[,1],
                       score_fcz,guess_fcz[,1],difference_fcz[,1],
                       score_gc,guess_gc[,1],difference_gc[,1],
                       score_lausanne,guess_lausanne[,1],difference_lausanne[,1],
                       score_servette,guess_servette[,1],difference_servette[,1]
                       )
colnames(new_data) <-  c("Name","Ø difference","robot beaten?",
                                             "Ø score YB","guess YB","difference YB",
                                             "Ø score Basel","guess Basel","difference Basel",
                                             "Ø score Lugano","guess Lugano","difference Lugano",
                                             "Ø score FCL","guess FCL","difference FCL",
                                             "Ø score Sion","guess Sion","difference Sion",
                                             "Ø score FCSG","guess FCSG","difference FCSG",
                                             "Ø score FCZ","guess FCZ","difference FCZ",
                                             "Ø score GC","guess GC","difference GC",
                                             "Ø score Lausanne","guess Lausanne","difference Lausanne",
                                             "Ø score Servette","guess Servette","difference Servette"
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

write.csv(ranking,file="Output/ranking_beattherobot.csv",row.names = FALSE, fileEncoding = "UTF-8")

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

overview$team <- c("YB","Basel","Lugano","FCL","Sion","FCSG","FCZ","GC","Lausanne","Servette","Ø difference")

write.csv(overview,file="Output/overview_beattherobot.csv",row.names = FALSE, fileEncoding = "UTF-8")

print(overview)
