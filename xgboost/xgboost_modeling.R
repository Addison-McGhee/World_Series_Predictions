library(tidyverse)
library(baseballr)
library(xgboost)
library(caret)
library(SHAPforxgboost)
library(varhandle)

ws_data = readRDS("ws_data.RDS") %>%
  select(-league_winner) %>% 
  mutate(year = unfactor(year))

#make this example reproducible
set.seed(0)

# Years we want to predict on
years = c(2000:2019, 2021:2022)

# Data.frame to store predictions
df_pred = data.frame(prob = c(1), team_name = c(""), year = c(1))
for(yr in years) {

  # Filter out year that we want to predict
  team_data = ws_data %>% 
    filter(year < yr) %>% 
    mutate(year = as.factor(year))
  
  print(table(team_data$year))
  #split into training (80%) and testing set (20%)
  parts = createDataPartition(team_data$world_series_winner, p = .8, list = F)
  train = team_data[parts, ]
  test = team_data[-parts, ]
  
  #define predictor and response variables in training set
  train_x = data.matrix(train %>% select(-world_series_winner))
  train_y = train$world_series_winner
  
  #define predictor and response variables in testing set
  test_x = data.matrix(test %>% select(-world_series_winner))
  test_y = test$world_series_winner
  
  #define final training and testing sets
  xgb_train = xgb.DMatrix(data = train_x, label = train_y)
  xgb_test = xgb.DMatrix(data = test_x, label = test_y)
  
  
  #define watchlist
  watchlist = list(train=xgb_train, test=xgb_test)
  
  #fit XGBoost model and display training and testing data at each round
  model = xgb.train(data = xgb_train, 
                    max.depth = 3, 
                    watchlist=watchlist, 
                    nrounds = 70,
                    objective = "binary:logistic",
                    verbose = F)
  
  
  #define final model
  best_rounds = which.min(model$evaluation_log$test_logloss)
  
  final = xgboost(data = xgb_train, 
                  max.depth = 3, 
                  nrounds = best_rounds, 
                  verbose = 0,
                  objective = "binary:logistic")
  
  
  # Generate predictions for specific year
  pred_data = ws_data %>%
    filter(year == yr) 
    
  pred_x = data.matrix(pred_data %>% select(-world_series_winner))
  pred_y = pred_data$world_series_winner
  
  temp_pred_data = xgb.DMatrix(data = pred_x, 
                               label = pred_y)
  
  
  pred <- data.frame(prob = predict(final, pred_x))
  pred$team_name = pred_data$team_name
  pred$year = rep(yr, nrow(pred))
  df_pred = rbind.data.frame(df_pred, pred)
  
  
}



df_pred = df_pred[-1, ]

df_pred %>% ggplot(aes(year, prob, color = team_name)) +
  geom_line()

write.csv(df_pred, "ws_prob_over_time.csv")




