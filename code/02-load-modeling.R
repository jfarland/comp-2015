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
load("temp-final.Rda")

#merge the data sets with a left join


temp_final <-
  temp_act %>%
  mutate(dindx = as.Date(tindx),
         hindx = hour(tindx)) %>%
  select(temp,dindx,hindx)

load_weather <-
  left_join(load.long, temp_final, by=c("dindx","hindx"))

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

summary(model_dat)
tail(model_dat,100)

#-----------------------------------------------------------------------------#
#
# Naive Forecasts - Univariate
#
#-----------------------------------------------------------------------------#

#assign univariate vector of load
y <- model_dat %>% select(tindx, load)

naive1 <- naive(y$load, 72)

#plot the naive forecasts
plot.forecast(naive1, plot.conf=TRUE, xlab=" ", ylab=" ",
              main="NAIVE", ) #ylim = c(0,25))

#performance metrics of the naive forecast
accuracy(naive)

means <-
  model_dat %>% group_by(hindx,mindx,dow) %>% summarize(mean_kwh = mean(load))

summary(means)

#initial forecast for 10/6 which is a tuesday
naive2 <- subset(means, dow=="Saturday" & mindx =="10")

View(naive2)

#-----------------------------------------------------------------------------#
#
# Time Series Models - Univariate
#
#-----------------------------------------------------------------------------#

# (2) traditional time series forecast
fcst1 <-forecast(y$load, h=72)

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
nnet  <-nnetar(y$load, 72)

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
sm1 <- gam(load ~  s(temp, bs="cp",k=22)+factor(dow)+factor(hindx)+factor(mindx)+lag72+lag96+lag120+lag144+lag168, family = "gaussian", data = model_dat,
            method = "REML", na.action=na.omit)

gam.check(sm1)
plot(fitted(sm1), residuals(sm1))
summary(sm1)
plot(sm1)
anova(sm1)

accuracy(sm1)
#todo : models by hour, add humidity and other atmospheric variables, add additional lags, add other weather stations

library(broom)

#try running hourly models instead
sm2 <- model_dat %>%
  group_by(hindx)%>%
  do(tidy(lm(load ~ temp+temp2+temp3+factor(dow)+factor(mindx)+lag72+lag96+lag120+lag144+lag168,data=.)))



#vis.gam(sm1, view=c("temp","temp2"),theta=200, thicktype="detailed",)


#-----------------------------------------------------------------------------#
#
# Production level forecasts
#
#-----------------------------------------------------------------------------#

#make production forecast dataset
#step 1 - time series forecast of load to create lags

#only keep predictors and forecasted temperature within range





#take forecasted timestamp and left join load


act <- model_dat %>%
  filter(dindx > "2015-09-01") %>%
  mutate(type = "act") %>%
  select(load,temp,dindx,hindx,mindx,dow,type)

fcst_1 <-
  temp_fcst %>%
  mutate(dindx = as.Date(tindx),
         hindx = hour(tindx),
         mindx = month(dindx),
         dow = weekdays(dindx),
         load = NA,
         type = "fcst") %>%
  select(load,temp,dindx,hindx,mindx,dow,type)


fcst_2 <-
  rbind(act, fcst_1)
 
#now create lags using most recent load data

cols <- dim(fcst_2)[2] #number of columns before we add lags

for (i in 1 : length(displacements))
{
  disp = displacements[i]
  fcst_2[,i+cols] <- unlist(shift(fcst_2$load, -1*disp))
  colnames(fcst_2)[c(i+cols)] = lagnames[i]
}


#isolate date to forecast using fitted model

forecast <-
  fcst_2 %>%
  filter(dindx > "2015-10-09") %>%
  filter(dindx < "2015-10-11") %>%
  select(temp,dindx,hindx,mindx,dow,type,lag72,lag96,lag120,lag144,lag168)
         
summary(forecast)

fcst_prime <- predict(sm1,newdata=forecast)

summary(fcst_prime)
plot(fcst_prime)

#todo: output forecasts         

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



write.csv(fcst_prime)
writeRDS()

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#