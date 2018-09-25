

#****************************************
# Master script: Analysis of LOS data 
#****************************************

library("ggplot2")
unloadNamespace("lubridate"); library("here")
library("fitdistrplus")
library("RODBC")
library("glue")

# rm(list=ls())


# PARAMETERS: ---------
cnx <- odbcConnect("cnx_SPDBSCSTA001") # ODBC connection
nursing.unit <- "SCO"
site = "Lions Gate Hospital"
admit.fiscal.year <- "2018"
transfer.date.after <- "2017-04-01"  # todo: rewrite query to automatically select right transfer date start point


# pull in clean data, function to calculate LOS, extract arrival timestamps: : 
source(here("src", 
            "2018-09-24_los-data-cleaning.R"))
source(here("src", 
            "los_function.R"))
source(here("src", 
            "arrival-timestamp_function.R"))



# ******************************
# Analysis for specified nursing unit ---------------
# ******************************

# 1) LOS calculation: --------------
# split data by unique encounter: 
split.losdata <- split(df2.losdata.clean, df2.losdata.clean$id)
# str(split.losdata)

# apply los.fn, then combine results into a vector: 
los.vec <- 
      lapply(split.losdata,
             los.fn, 
             nursingunit = "ICU")  %>%  # nursingunit is passed to los.fn
      unlist %>% unname 
str(los.vec)
summary(los.vec)


los.df <- as.data.frame(los.vec)  # easier to work with in ggplot 
str(los.df)

# tables of results: 
summary <- 
      summarise(los.df,
          unit="ICU", 
          mean=mean(los.vec, na.rm=TRUE), 
          median=quantile(los.vec, probs = .50, na.rm=TRUE), 
          x90th.perc=quantile(los.vec, probs = .90, na.rm=TRUE))

table.los <- table(los.vec) %>% as.data.frame




# 2) Visualize LOS distribution: ----------
plotdist(los.vec)
descdist(los.vec[!is.na(los.vec)], boot=1000)  # gamma might be good fit





#******************************
# Plotting with ggplot: ------------
#******************************

# todo: fix subtitles 

# > Graphs for ICU --------
p1_hist <- 
      ggplot(los.df, 
             aes(x=los.vec)) + 
      geom_histogram(stat="bin", 
                     binwidth = 1, 
                     col="black", 
                     fill="deepskyblue") + 
      
      scale_x_continuous(limits=c(-1,85), 
                         breaks=seq(0,85,5), 
                         expand=c(0,0)) + 
      scale_y_continuous(expand=c(0,0)) + 
      
      labs(x="LOS in days", 
           y="Number of cases", 
           title=paste0("Distribution of LOS in ", 
                        site, 
                        " ", 
                        nursing.unit), 
           subtitle=paste0("FY 2017/18 \nMedian = ", 
                           summary$median %>% as.numeric %>% round(1), 
                           " days; Mean = ",
                           summary$mean %>% as.numeric %>% round(1),
                           " days \nNumber of cases = ", 
                           nrow(los.df), 
                           "\n\n"), 
           caption= "\nData source: DSDW ADTCMart; extraction date: 2018-09-24 ") + 
      
      geom_vline(xintercept = summary[,2], 
                 col="red") + 
      
      geom_vline(xintercept = summary[,3], 
                 col="red", 
                 linetype=2) + 
      
      theme_classic(base_size = 16); p1_hist


# save output (change filename first): 
unloadNamespace("lubridate")
ggsave(here("results", 
            "output from src", 
            as.character(glue("2018-09-24_lgh_los-in-{nursing.unit}.pdf"))))


