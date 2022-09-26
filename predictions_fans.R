#Get Tips
tips <- read_csv(tips_path)

#Eliminate double entries
tips <- tips %>%
  distinct(`E-Mail-Adresse`, .keep_all=TRUE)

predictions_fans <- data.frame("match",0.55,0.55,0.55)
colnames(predictions_fans) <- c("match","win home","draw","win away")

for (i in c(2:3,6:8) ) {

counts <- as.data.frame(table(tips[i]))

win_home <- counts[counts$Var1 == "win home",2]/nrow(tips)

if (length(win_home) == 0) {
  
win_home <- 0  
  
}  

draw <- counts[counts$Var1 == "draw",2]/nrow(tips)

if (length(draw) == 0) {
  
  draw<- 0  
  
}  

win_away <- counts[counts$Var1 == "win away",2]/nrow(tips)

if (length(win_away) == 0) {
  
  win_away <- 0  
  
}  


match <- str_sub(colnames(tips[i]),2,-2)



new_entry <- data.frame(match,win_home,draw,win_away)
colnames(new_entry) <- c("match","win home","draw","win away")

predictions_fans <- rbind(predictions_fans,new_entry)

}

predictions_fans <- predictions_fans[-1,]
write.csv(predictions_fans,file="Output/predictions_fans.csv",row.names = FALSE, fileEncoding = "UTF-8")

print(predictions_fans)
