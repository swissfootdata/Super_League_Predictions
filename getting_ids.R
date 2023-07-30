url <- "https://www.transfermarkt.ch/super-league/gesamtspielplan/wettbewerb/C1/saison_id/2023"
webpage <- read_html(url)

ids_id <- webpage %>%
  html_nodes(xpath = "//td/a") %>%
  html_attr("href")

ids <- data.frame(ids_id)
ids$check <- grepl("spielbericht",ids$ids_id)

ids <- na.omit(ids[ids$check == TRUE,])

new_matches_all <- as.integer(gsub(".*spielbericht/", "",ids$ids_id))

played_matches <- (as.numeric(round))*6

games <- new_matches_all[(played_matches-5):played_matches]

new_matches <- new_matches_all[(played_matches+1):length(new_matches_all)]

print(paste0(length(new_matches)," matches found"))

