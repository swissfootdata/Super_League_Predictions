library(readxl)
library(mgcv)
library(dplyr)
library(rvest)
library(stringr)
library(XML)
library(readr)
library(dplyr)


#Create model
coaches_old <- read_excel("./Coaches/coaches.xlsx")
fit <- gam(Spiele ~ s(PPS) + Verein, data=coaches_old)

#Get data for current coaches
for (c in 1:nrow(coaches)) {
  
team <- coaches$coaches_teams[c]
coach <- coaches$coaches_names[c]
PPS <- 0
weights <- c(1.4,1.3,1.2,1.1,1,0.9,0.8,0.7,0.6)
  
team_data <- data_transfermarkt[data_transfermarkt$team_home == team  | 
                                  data_transfermarkt$team_away == team , c(3:4,9,33:34,57:58)]


team_data <- na.omit(team_data[team_data$coach_home == coach|
                         team_data$coach_away == coach,])

team_data <- team_data[rev(order(team_data$date)),]


if (nrow(team_data) > 8) {
  
 team_data <- team_data[1:9,] 
  
for (t in 1:nrow(team_data)) {
  
 if (team_data$team_home[t] == team) {

  PPS <- PPS + team_data$points_home[t]*weights[t]
      
 } else {
  
   PPS <- PPS + team_data$points_away[t]*weights[t]
}
     
}
 
coaches$PPS[c] <- PPS/9
 
}  

}

#Add new data to predictions
new_data <- coaches[,c(2:3)]
colnames(new_data) <- c("Verein","PPS")


coaches$`Games left` <- predict.gam(fit,new_data)

coaches$prediction <- "Too few matches for a prediction"

coaches_old$Meisterschaften <- as.numeric(coaches_old$Meisterschaften)
coaches_old$Meisterschaften[is.na(coaches_old$Meisterschaften)] <- 0

#Make it harder for top teams
coaches_old <- coaches_old %>%
  group_by(Verein) %>%
  summarise(titles = sum(Meisterschaften))


coaches <- merge(coaches,coaches_old,by.x="coaches_teams",by.y = "Verein")
coaches$`Games left` <- coaches$`Games left`-coaches$titles

for (i in 1:nrow(coaches)) {
  
  if (is.na(coaches$`Games left`[i]) == FALSE) {

if (coaches$`Games left`[i] > 70) {
 
  coaches$alert_level[i] <- 1
 coaches$prediction[i] <- "Can stay as long as he wants!"
   
} else if (coaches$`Games left`[i] > 60) {
  
  coaches$alert_level[i] <- 2
  coaches$prediction[i] <- "Does have nothing to worry about!"
  
} else if (coaches$`Games left`[i] > 55) {
  
  coaches$alert_level[i] <- 3
  coaches$prediction[i] <- "Should keep his job a while"
  
} else if (coaches$`Games left`[i] > 45) {
  
  coaches$alert_level[i] <- 4
  coaches$prediction[i] <- "Doing just fine"
  
} else if (coaches$`Games left`[i] > 40) {
  
  coaches$alert_level[i] <- 5
  coaches$prediction[i] <- "Is still safe, for now"
  
} else if (coaches$`Games left`[i] > 35) {
  
  coaches$alert_level[i] <- 6
  coaches$prediction[i] <- "Should start to worry..."
  
} else if (coaches$`Games left`[i] > 30) {
  
  coaches$alert_level[i] <- 7
  coaches$prediction[i] <- "Should start winning soon!"
  
} else if (coaches$`Games left`[i] > 20) {
  
  coaches$alert_level[i] <- 8
  coaches$prediction[i] <- "Needs a win badly!"
  
} else if (coaches$`Games left`[i] > 10) {
  
  coaches$alert_level[i] <- 9
  coaches$prediction[i] <- "Will get fired soon!"
  
} else if (coaches$`Games left`[i] <= 10) {
  
  coaches$alert_level[i] <- 10
  coaches$prediction[i] <- "Is doomed no matter what!!!"
  
}
}
}

#Adaptations
coaches <- coaches[order(-coaches$alert_level,coaches$`Games left`),]
coaches$coaches_names <- paste0(coaches$coaches_names," (",coaches$coaches_teams,")")

write.csv(coaches,file="./Output/coaches_alert.csv",row.names = FALSE, fileEncoding="UTF-8")
print(coaches)
