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
library("quantreg")
library("quantregForest")
library("mgcv")

#-----------------------------------------------------------------------------#
#
# Setup / Options
#
#-----------------------------------------------------------------------------#

# Current Directory
getwd()

#set the raw data as the current directory
setwd("/home/rstudio/projects/comp-2015/data/")

#-----------------------------------------------------------------------------#
#
# Load Inputs
#
#-----------------------------------------------------------------------------#

load("load-long.Rda")
load("weather.Rda")

#merge the data sets with a left join
load_weather <-
  left_join(load.long, weather, by=c("dindx","hindx")) %>%
  rename(temp = TemperatureF)

summary(load_weather)

plot(load_weather$temp, load_weather$load)

#-----------------------------------------------------------------------------#
#
# Prepare Modeling Data Set
#
#-----------------------------------------------------------------------------#

#create lag and lead variables
#source <- http://ctszkin.com/2012/03/11/generating-a-laglead-variables/
shift<-function(x,shift_by){
  stopifnot(is.numeric(shift_by))
  stopifnot(is.numeric(x))
  
  if (length(shift_by)>1)
    return(sapply(shift_by,shift, x=x))
  
  out<-NULL
  abs_shift_by=abs(shift_by)
  if (shift_by > 0 )
    out<-c(tail(x,-abs_shift_by),rep(NA,abs_shift_by))
  else if (shift_by < 0 )
    out<-c(rep(NA,abs_shift_by), head(x,-abs_shift_by))
  else
    out<-x
  out
}

#date<- ISOdate(trn0$year, trn0$month, trn0$day)


#create lag variables of load
displacements <- seq(24, 168, 24)

#vector of column names
lagnames <- paste("lag", displacements, sep = "")

cols <- dim(load_weather)[2] #number of columns before we add lags

for (i in 1 : length(displacements))
{
  disp = displacements[i]
  load_weather[,i+cols] <- unlist(shift(load_weather$load, -1*disp))
  colnames(load_weather)[c(i+cols)] = lagnames[i]
}

# for (i in 1 : length(displacements))
# {
#   disp = displacements[i]
#   tst0[,i+cols] <- unlist(shift(tst0$load, -1*disp))
#   colnames(tst0)[c(i+cols)] = lagnames[i]

#finally create higher order temperature variables

model_dat <-
  load_weather %>%
  mutate(temp2 = temp*temp,
         temp3 = temp*temp*temp)  

#-----------------------------------------------------------------------------#
#
# Naive Forecasts - Univariate
#
#-----------------------------------------------------------------------------#

#assign univariate vector of load
y <- model_dat$load

naive1 <- naive(y, 36)

#plot the naive forecasts
plot.forecast(naive1, plot.conf=TRUE, xlab=" ", ylab=" ",
              main="NAIVE", ) #ylim = c(0,25))

#performance metrics of the naive forecast
accuracy(naive)


means <-
  load.long %>% group_by(hindx,mindx, dow) %>% summarize(mean_kwh = mean(load))

summary(means)

#initial forecast for 10/6 which is a tuesday
naive2 <- subset(means, dow=="Thursday" & mindx =="10")

View(naive2)

#-----------------------------------------------------------------------------#
#
# Time Series Models - Univariate
#
#-----------------------------------------------------------------------------#

# (2) traditional time series forecast
fcst1 <-forecast(y, h=36)

#plot traditional forecasts
plot.forecast(fcst1, plot.conf=TRUE, xlab=" ", ylab=" ", 
              main="Univariate Time Series", )#ylim = c(0,25))

#performance metrics of the traditional time series forecast
accuracy(fcst1)

#view forecasts and prediction intervals
summary(fcst1)

#-----------------------------------------------------------------------------#
#
# Artificial Intelligence - Univariate
#
#-----------------------------------------------------------------------------#

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
# Quintile Regression - Multivariate
#
#-----------------------------------------------------------------------------#


#Quantile Regression
rq1 = rq(load~temp+temp2+temp3+factor(dow)+factor(hindx)+factor(mindx)+lag24+lag48+lag72+lag96+lag120+lag144+lag168,tau=seq(0.01, 0.99, 0.01), load_weather)

postscript("quintiles.pdf", horizontal = FALSE, width = 6.5, height = 3.5)
plot(rq1, nrow=1, ncol=2)
dev.off()

#-----------------------------------------------------------------------------#
#
# Semiparametric Regression - Multivariate
#
#-----------------------------------------------------------------------------#


#Semiparametric Model
sm1 <- gam(load ~  s(temp, bs="cp",k=22)+s(temp2, bs="cp",k=22)+ s(temp3, bs="cp")+factor(dow)+factor(hindx)+factor(mindx)+lag24+lag48+lag72+lag96+lag120+lag144+lag168, family = "gaussian", data = load_weather,
            method = "REML", na.action=na.omit)

gam.check(sm1)
plot(fitted(sm1), residuals(sm1))
summary(sm1)
plot(sm1)
anova(sm1)

accuracy(sm1)

#vis.gam(sm1, view=c("temp","temp2"),theta=200, thicktype="detailed",)


#-----------------------------------------------------------------------------#
#
# Production level forecasts
#
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#
# Forecast Optimization
#
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#
# Outputs
#
#-----------------------------------------------------------------------------#



write.csv()
writeRDS()

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#