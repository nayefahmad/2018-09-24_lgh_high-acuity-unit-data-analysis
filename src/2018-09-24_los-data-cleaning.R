

#**********************************
# Script to clean data for example dataset: 
#**********************************

unloadNamespace("lubridate"); library("here") # lubridate doesn't play well with here( ) package
library("readr")

# rm(list=ls())


# import data cleaning function: ------
source(here("src", 
            "data-cleaning_function.R"))

# import data using RODBC: --------
source(here("src", 
            "2018-09-24_sql-query-for-pulling-LOS-data.R"))


#********************************
# Cleaning data: -----------
#********************************
library("lubridate")  # has to be loaded after use of here( ) function

df2.losdata.clean <- clean.los(df1.losdata)  # NAs returned for pts not discharged yet

str(df2.losdata.clean)
summary(df2.losdata.clean)
summary(select(df2.losdata.clean, 6:8))
head(df2.losdata.clean)


# save reformatted data: ----------------
unloadNamespace("lubridate")

# write_csv(df2.losdata.clean,
#           here("results", 
#                "output from src", 
#                "2018-09-24_lgh_clean-los-data.csv"))


