library(tidyverse)
library(baseballr)
library(ggrepel)

# Team ID list
# https://github.com/jasonlttl/gameday-api-docs/blob/master/team-information.md

team_ids = c(108:121, 133:147, 158)
years = c(1998:2019, 2021:2022)

historic_team_data = mlb_team_stats(team_id = team_ids[1], 
                                    stat_type = 'season', 
                                    stat_group = 'hitting', 
                                    season = years[1])
count = 1
for(id in team_ids) {
  print(id)
  for(year in years) {
    historic_team_data = rbind.data.frame(
      historic_team_data,
      mlb_team_stats(team_id = id, 
                     stat_type = 'season', 
                     stat_group = 'hitting', 
                     season = year)
    )
    print(count)
    count = count + 1
  }
}

historic_team_data = historic_team_data[-1, ]
historic_team_data$season = as.numeric(historic_team_data$season)
historic_team_data$team_name[historic_team_data$team_name == "Cleveland Indians"] = "Cleveland Guardians"
historic_team_data$team_name[historic_team_data$team_name == "Florida Marlins"] = "Miami Marlins"
historic_team_data$team_name[historic_team_data$team_name == "Anaheim Angels"] = "Los Angeles Angels"
historic_team_data$team_name[historic_team_data$team_name == "Tampa Bay Devil Rays"] = "Tampa Bay Rays"
historic_team_data$team_name[historic_team_data$team_name == "Montreal Expos"] = "Washington Nationals"
saveRDS(historic_team_data, "historic_team_data.RDS")



