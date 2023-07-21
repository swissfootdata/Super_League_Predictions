url <- paste0("https://www.transfermarkt.ch/super-league/trainervergleich/wettbewerb/C1")
webpage <- read_html(url)

coaches_data <- html_text(html_nodes(webpage,"a"))

coaches_data
start <- which(grepl("PPS",coaches_data))[1]

coaches_data <- coaches_data[start:length(coaches_data)]

coaches_names <- c(coaches_data[3],coaches_data[7],coaches_data[11],coaches_data[15],coaches_data[19],
                   coaches_data[23],coaches_data[27],coaches_data[31],coaches_data[35],coaches_data[39],
                   coaches_data[43],coaches_data[47])

coaches_teams <- c(coaches_data[4],coaches_data[8],coaches_data[12],coaches_data[16],coaches_data[20],
                   coaches_data[24],coaches_data[28],coaches_data[32],coaches_data[36],coaches_data[40],
                   coaches_data[44],coaches_data[48])


coaches <- data.frame(coaches_names,coaches_teams)

coaches$PPS <- NA
coaches$alert_level <- 0

print(coaches)
