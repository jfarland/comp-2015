

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
# Short Term Load Forecasting Competiion - Tao Hong's Energy Analytics Course
#
# Prepare and manage data sets used in forecasting
#
# Author: Jon T Farland <jon.farland@dnvgl.com>
#
# Copywright September 2015
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

library("ggplot2")
library("lattice")
library("dplyr")
library("tidyr")
library("gdata")
library("reshape2")
library("forecast")

#-----------------------------------------------------------------------------#
#
# Setup / Options
#
#-----------------------------------------------------------------------------#

# Current Directory
getwd()

#set the raw data as the current directory
setwd("/home/rstudio/projects/comp-2015/data/rawdat")

#-----------------------------------------------------------------------------#
#
# Load Inputs
#
#-----------------------------------------------------------------------------#


#uncomment the next command to run a Python script to download PJM load data for the last 5 years
#system('python /home/rstudio/projects/comp-2015/data/rawdat/00-pull-historical-load-data.py')

#download just the 2015 data as the competition ensues
system('python /home/rstudio/projects/comp-2015/data/rawdat/00-pull-2015-load-data.py')

#Read in only the dominion tab of the excel spreadsheets
load11 <- read.xls("load11.xls", sheet=22) %>%
  select(DATE:HE24)
load12 <- read.xls("load12.xls", sheet=22) %>%
  select(DATE:HE24)
load13 <- read.xls("load13.xls", sheet=22) %>%
  select(DATE:HE24)
load14 <- read.xls("load14.xls", sheet=22) %>%
  select(DATE:HE24)
load15 <- read.xls("load15.xls", sheet=22) %>%
  select(DATE:HE24)

load.data=rbind(load11, load12, load13, load14, load15)

#-----------------------------------------------------------------------------#
#
# Processing
#
#-----------------------------------------------------------------------------#


#go from wide to long
load.long <- melt(load.data, id=c("DATE", "COMP")) %>%
  rename(hour = variable, load = value) %>%
  mutate(tindx = mdy_h(paste(DATE, substr(hour, 3, 4)))-duration(1,"hours"),
         hindx = hour(tindx),
         dindx = as.Date(tindx),
         mindx = month(tindx),
         dow   = weekdays(tindx)) %>%
  select(tindx, hindx, dindx, mindx, load, dow) %>%
  arrange(dindx, hindx)

#shifted to hour beginning rather than hour ending

#quick checks
summary(load.long)

#-----------------------------------------------------------------------------#
#
# Graphics
#
#-----------------------------------------------------------------------------#

# load over time
plot1 <- plot(load.long$load ~ load.long$tindx)
plot2 <- plot(load.long$load ~ load.long$hindx)
plot3 <- plot(load.long$load ~ load.long$dindx)

#histograms and conditional histograms
histogram(~load | mindx, data = load.long, xlab="Load (MW)", ylab ="Density", col=c("red"))
histogram(~load | hindx, data = load.long, xlab="Load (MW)", ylab ="Density", col=c("red"))
histogram(~load , data = load.long, xlab="Load (MW)", ylab ="Density", col=c("red"))

#-----------------------------------------------------------------------------#
#
# Preliminary forecasts
#
#-----------------------------------------------------------------------------#

y <- load.long$load

naive <- naive(y, 36)

#plot the naive forecasts
plot.forecast(naive, plot.conf=TRUE, xlab=" ", ylab=" ",
              main="NAIVE", ) #ylim = c(0,25))

#performance metrics of the naive forecast
accuracy(naive)

# (2) traditional time series forecast
fcst1 <-forecast(y, h=36)

#plot traditional forecasts
plot.forecast(fcst1, plot.conf=TRUE, xlab=" ", ylab=" ", 
              main="Univariate Time Series", )#ylim = c(0,25))

#performance metrics of the traditional time series forecast
accuracy(fcst1)

#view forecasts and prediction intervals
summary(fcst1)


# (3) make an artificial neural net
nnet  <-nnetar(y, 36)

#use the neural net to produce forecasts
fcst2 <- forecast(nnet)

#plot traditional forecasts
plot.forecast(fcst2, plot.conf=TRUE, xlab=" ", ylab=" ",
              main="Artificial Intelligence")#, ylim = c(0,25))

#performance metrics of the traditional time series forecast
accuracy(fcst2)

#view forecasts 
summary(fcst2)

#-----------------------------------------------------------------------------#
#
# Outputs
#
#-----------------------------------------------------------------------------#

means <-
  load.long %>% group_by(hindx, dow) %>% summarize(mean_kwh = mean(load))

summary(means)

#initial forecast for 10/6 which is a tuesday
fcst0 <- subset(means, dow=="Tuesday")

View(fcst0)


#-----------------------------------------------------------------------------#
#
# Outputs
#
#-----------------------------------------------------------------------------#

write.csv()
writeRDS()

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#