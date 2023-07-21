guesses_players <- read_excel("BeatTheRobot_4/season_predictions_23_24.xlsx")
guesses_players$champ <- NA
guesses_players$relegated <- NA


for (n in 1:nrow(guesses_players)) {
guesses_players$champ[n] <- names(which.max(guesses_players[n,8:20]))[1]
guesses_players$relegated[n] <- names(which.min(guesses_players[n,8:20]))[1]
}
 
#Transform Data to long
library(tidyr)
guesses_players$player <- paste0(guesses_players$first_name," ",guesses_players$last_name)


long_data <- guesses_players[,c(22,8:19)]
long_data <- pivot_longer(long_data,
                     cols=colnames(long_data[,2:13]))
colnames(long_data) <- c("player","team","points")

write.csv(long_data,"beat_the_robot_4_long_data.csv",row.names = FALSE)
