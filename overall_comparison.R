#Get current Leaderboard

mydb <- dbConnect(MySQL(), user='Administrator', password='tqYYDcqx43', dbname='football_data', host='33796.hostserv.eu', encoding="utf8")
dbGetQuery(mydb, "SET NAMES 'utf8'")

rs <- dbSendQuery(mydb, "SELECT * FROM leaderboard_btr")
leaderboard <- fetch(rs,n=-1, encoding="utf8")
Encoding(leaderboard$email) <- "UTF-8"
Encoding(leaderboard$name) <- "UTF-8"
Encoding(leaderboard$twitter) <- "UTF-8"

accuracy_players <- sum(leaderboard$correct_guesses)/(sum(leaderboard$correct_guesses)+sum(leaderboard$wrong_guesses))
accuracy_robot <- mean(performance_robot$accuracy)

data_transfermarkt_select <- data_transfermarkt[data_transfermarkt$season == "20/21",]

leaderboard_select <- leaderboard[leaderboard$rounds_played > 9]
hist(leaderboard_select$accuracy, breaks=20)
summary(leaderboard_select$accuracy)
