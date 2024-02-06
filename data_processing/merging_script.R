library(Lahman)
library(tidyverse)
library(baseballr)
library(ggrepel)

filtered_data = read.csv("mlb_teams.csv")

# Load Lahman data and remove extra columns
mlb_data = Lahman::Teams %>% 
  select(-c(teamID, franchID, teamIDretro, teamIDlahman45, teamIDBR, PPF, BPF))

# Rename columns to match
colnames(mlb_data) = colnames(filtered_data)

# Filter seasons and fix team names
mlb_data = mlb_data %>% 
  filter(year >= 1998 & year != 2020) %>% 
  mutate(team_name = case_when(
    team_name == "Cleveland Indians" ~ "Cleveland Guardians",
    team_name == "Anaheim Angels" ~ "Los Angeles Angels",
    team_name == "Florida Marlins" ~ "Miami Marlins",
    team_name == "Tampa Bay Devil Rays" ~ "Tampa Bay Rays",
    team_name == "Montreal Expos" ~ "Washington Nationals",
    team_name == "Los Angeles Angels of Anaheim" ~ "Los Angeles Angels",
    TRUE ~ team_name
    )
  )


# Create factors
mlb_data = mlb_data %>% 
  mutate(team_name = as.factor(team_name),
         year = as.factor(year),
         league_id = as.factor(league_id),
         division_id = as.factor(division_id),
         rank = fct_rev(factor(rank, ordered = T)),
         ball_park = as.factor(ball_park),
         division_winner = as.factor(division_winner),
         wild_card_winner = as.factor(wild_card_winner),
         league_winner = as.factor(league_winner),  
         world_series_winner = ifelse(world_series_winner == "Y", 1, 0))

saveRDS(mlb_data, "final_mlb_data.RDS")


# Load older data with OPS, BA, SLG, etc.
historic_team_data = readRDS("historic_team_data.RDS") %>% 
  filter(!year %in% c(2020, 2023)) %>% 
  select(-c(team_id, team_link, type_display_name, group_display_name)) %>% 
  mutate(season = as.factor(season),
         avg = as.numeric(avg),
         obp = as.numeric(obp),
         slg = as.numeric(slg),
         ops = as.numeric(ops),
         stolen_base_percentage = as.numeric(stolen_base_percentage),
         babip = as.numeric(babip),
         ground_outs_to_airouts = as.numeric(ground_outs_to_airouts),
         team_name = as.factor(team_name)) %>% 
  select(season,
         team_name, 
         avg,
         obp,
         slg,
         ops,
         stolen_base_percentage,
         babip,
         ground_outs_to_airouts,
         team_name,)



# Merge Datasets
mlb_data = readRDS("final_mlb_data.RDS")

ws_data = mlb_data %>% 
  left_join(historic_team_data, by = c("year" = "season", "team_name" = "team_name"))

# Save data
saveRDS(ws_data, "ws_data.RDS")




