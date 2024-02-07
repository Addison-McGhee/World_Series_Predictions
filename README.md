# World Series Win Probabilities by Season
The following repo contains the R code used to generate the World Series Win Probabilities for every MLB team from 2000 to 2022. An XGBoost model was trained using historical MLB data from 1999 to 2022, with 80% of the data used as the training set, and the remaining 20% used as the test set. The **Tableau** dashboard showing the results is available [here](https://addison-mcghee.github.io/MLB.html).

## Data
The data cleaning/processing code is in the data_processing folder. The data was obtained from a variety of sources. The team statistics by season were scraped from MLB.com using the `baseballr` package. The final standings/records for each team were obtained from the Sean Lahman baseball database using the `lahmnan` R package.

## Model Code
The modeling code is contained in the xgboost folder. The model was fit using the R `xgboost` package.
