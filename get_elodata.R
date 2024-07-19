get_elodata <- function() {


teams <- c("YoungBoys","Basel","StGallen","Servette","Luzern","Zuerich","Lugano","Lausanne","Winterthur","Grasshoppers","YverdonSport","LausanneOuchy","Sion")

elo_values <- data.frame("None","bla","SUI",0,0,Sys.Date(),Sys.Date())
colnames(elo_values) <- c("Rank","Club","Country","Level","Elo","From","To")

for (i in teams) {


res <- GET(paste0("http://api.clubelo.com/",i))
data <- as.data.frame(content(res,"parsed"))

elo_values <- rbind(elo_values,data)

print(paste0("Elo-Values scraped from ",data$Club[1]))

}

elo_values <- elo_values[-1,]
elo_values <- elo_values[elo_values$From >= 2010-01-01,]

return(elo_values)

}


elo_values <- get_elodata()

elo_values$Club <- gsub("Aarau","FC Aarau",elo_values$Club)
elo_values$Club <- gsub("Basel","FC Basel 1893",elo_values$Club)
elo_values$Club <- gsub("Grasshoppers","Grasshopper Club Zürich",elo_values$Club)
elo_values$Club <- gsub("Lausanne","FC Lausanne-Sport",elo_values$Club)
elo_values$Club <- gsub("Lugano","FC Lugano",elo_values$Club)
elo_values$Club <- gsub("Luzern","FC Luzern",elo_values$Club)
elo_values$Club <- gsub("Servette","Servette FC",elo_values$Club)
elo_values$Club <- gsub("Sion","FC Sion",elo_values$Club)
elo_values$Club <- gsub("StGallen","FC St. Gallen 1879",elo_values$Club)
elo_values$Club <- gsub("Thun","FC Thun",elo_values$Club)
elo_values$Club <- gsub("Vaduz","FC Vaduz",elo_values$Club)
elo_values$Club <- gsub("Xamax","Neuchâtel Xamax FCS",elo_values$Club)
elo_values$Club <- gsub("Young Boys","BSC Young Boys",elo_values$Club)
elo_values$Club <- gsub("Zuerich","FC Zürich",elo_values$Club)
elo_values$Club <- gsub("Winterthur","FC Winterthur",elo_values$Club)
elo_values$Club <- gsub("Yverdon Sport","Yverdon Sport FC",elo_values$Club)
elo_values$Club <- gsub("FC Lausanne[-]Sport Ouchy","FC Stade-Lausanne-Ouchy",elo_values$Club)