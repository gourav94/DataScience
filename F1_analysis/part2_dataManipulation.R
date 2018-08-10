#Necessary packages to be loaded 
library(dplyr)
library(ggplot2)
library(tidyverse)
library(lubridate)

#Import the dataset
F1_races <- read_csv("~/career/datascience/DataCamp/datasets/F1/F1_races.csv",col_types = cols(Timing = col_character()))
#Get to know the dataset more by seeing its structure 
head(F1_races)
glimpse(F1_races)


#Remove X1 column as it is unnecessary

race <- F1_races %>%
  select(-X1) # Selects all the columns except X1 and stores the resulting outout as tibble dataframe
#Data Manipulations steps
summary(race)

#Extract year from the date column and store is separately. 
race <- mutate(race, Year = str_sub(DATE, -4)) 
#Convert the year column to numeric, and the existing Date to date format, Laps to numeric
race <- mutate(race, Year = as.numeric(Year),DATE = as.Date(DATE, "%d %b %Y"), Laps = as.numeric(Laps))
#Filter the column Timing that has Null values or NAs
race <- filter(race, !is.na(Timing))
#Convert the timing from string to time object. 
race <- mutate(race, Timing = as.POSIXct(Timing, format='%H:%M:%OS'))

#The resulting output might be a little shocking, because the timing has a date now. Well why to convert
#this format. This format is more useful while plotting. When you want to display, you convert them back to strings using the str_sub function as used above.
#MAKE SURE that there are milliseconds available. This is a RACE! Every millisecond counts!
#Gathering data to plot

#Summarise the Car victories
Car_summary <- race %>% group_by(Car)%>%summarise(Victories = n())
Car_summary <- Car_summary %>% arrange(desc(Victories))
#Extract the top 10 cars with most number of race victories
top_10 <- head(Car_summary, n= 10)
#plot them
ggplot(top_10, aes(x = Car, y = Victories))+ geom_bar(fill= "royalblue4",stat = "identity", width = 0.75)+geom_text(label = paste(sprintf("%s", top_10$Victories)),vjust = -1) + theme_minimal()

#Summarise with the Driver and Team combo victories
Team_summ <- race %>% group_by(Winner, Car) %>% summarise(Victories = n())
Team_summ <- arrange(Team_summ, desc(Victories))

#Summary of drivers with their victories
Driver_summ <- race %>% group_by(Winner) %>% summarise(Victories = n())
Driver_summ <- arrange(Driver_summ, desc(Victories))

#Extract the top 10 drivers with most race victories
top_drivers <- head(Driver_summ, n= 10)

#Extract the top10 drivers victories from the Team_summ tibble df by using semi_join
top_combo <- semi_join(Team_summ,top_drivers, by = "Winner")

#Plot the combo. Use Car and GrandPrix and Winner as factors
ggplot(top_combo, aes(x = factor(Winner), y = Victories, group = factor(Car),fill = factor(Car))) + geom_bar(color = "black",stat = "identity", position= "dodge")

#Although the plot looks nice with all the required features we want, it is quite difficult to grasp as there are 24 colours assigned in the legend. There are 24 Car teams.
#Hence it is strongly recommended to add a different feature to distinguish among the Car teams the various driver has drove. Probably simple text will do the trick.

#Write the resulting summary to a new csv file.
write_csv(top_combo, "viz_f1.csv")
