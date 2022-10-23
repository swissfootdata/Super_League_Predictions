market_values <- data.frame("aaa","bbb","ccc","dddd")
colnames(market_values) <- c("season","club","value","players")

url <- "https://www.transfermarkt.ch/super-league/marktwerteverein/wettbewerb/C1/stichtag//plus/1"
webpage <- read_html(url)

data <- html_text(html_nodes(webpage,"td"))
data <- data[-c(1:15)]


for (i in seq(1,100,10)) {

club <- data[i]
value <- data[i+4]
players <- data[i+5]

new_data <- data.frame(season,club,value,players)
colnames(new_data) <- c("season","club","value","players")
market_values <- rbind(market_values,new_data)

}  

market_values <- market_values[-1,]
market_values$value <- gsub(",",".",market_values$value)
market_values$value <- as.numeric(str_extract(market_values$value, "\\d+\\.*\\d*"))


market_values$players <- as.numeric(as.character(market_values$players))
market_values$average <- market_values$value/market_values$players

market_values <- market_values[order(-market_values$value),]
market_values$ranking <- 1:10

market_values <- market_values[,-4]
market_values$season <- as.character(market_values$season)
market_values$club <- as.character(market_values$club)


print(market_values)
