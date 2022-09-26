url <- "https://www.transfermarkt.ch/super-league/gesamtspielplan/wettbewerb/C1/saison_id/2022"
webpage <- read_html(url)

ids_id <- webpage %>%
  html_nodes(xpath = "//td/a") %>%
  html_attr("href")

ids <- data.frame(ids_id)
ids$check <- grepl("spielbericht",ids$ids_id)

ids <- na.omit(ids[ids$check == TRUE,])

new_matches <- as.integer(gsub(".*spielbericht/", "",ids$ids_id))

played_matches <- (as.numeric(round))*5

games <- new_matches[(played_matches-4):played_matches]

new_matches <- new_matches[(played_matches+1):length(new_matches)]

print(paste0(length(new_matches)," matches found"))

