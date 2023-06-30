for (i in 1:2) {
market_values <- rbind(market_values,market_values[nrow(market_values),])
}

market_values$club[9] <- "FC Lausanne-Sport"
market_values$value[9] <- 9.30
market_values$average[9] <- 9.30/24
market_values$ranking[9] <- 10
market_values$ranking[10] <- 9

market_values$club[11] <- "FC Stade-Lausanne-Ouchy"
market_values$value[11] <- 6.8
market_values$average[11] <- 6.8/27
market_values$ranking[11] <- 11

market_values$club[12] <- "Yverdon Sport FC"
market_values$value[12] <- 5.35
market_values$average[12] <- 5.35/27
market_values$ranking[12] <- 12

tabelle <- tabelle[c(8,2,11,7,1,4,9,5,3,6,10,12),]

for (i in 1:2) {
elo_values <- rbind(elo_values,elo_values[nrow(elo_values),])
}

elo_values$Club[nrow(elo_values)-2] <- "FC Lausanne-Sport"
elo_values$Elo[nrow(elo_values)-2] <- 1345.719
elo_values$To[nrow(elo_values)-2] <- Sys.Date()-1

elo_values$Club[nrow(elo_values)-1] <- "FC Stade-Lausanne-Ouchy"
elo_values$Elo[nrow(elo_values)-1] <- 1335.719
elo_values$To[nrow(elo_values)-1] <- Sys.Date()-1

elo_values$Club[nrow(elo_values)] <- "Yverdon Sport FC"
elo_values$Elo[nrow(elo_values)] <- 1299.719
elo_values$To[nrow(elo_values)] <- Sys.Date()-1
