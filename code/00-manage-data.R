

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
# [Project Title] - [Project Number]
#
# [Purpose of the code]
#
# Manager : <first.last@dnvgl.com>
# Author  : <first.last@dnvgl.com>
# Date    :
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

library("ggplot2")
library("lattice")
library("dplyr")
library("tidyr")
library("gdata")
library("reshape2")




#-----------------------------------------------------------------------------#
#
# Setup / Options
#
#-----------------------------------------------------------------------------#

# Current Directory
getwd()
setwd()

#-----------------------------------------------------------------------------#
#
# Load Inputs
#
#-----------------------------------------------------------------------------#

#csv file
data<-read.csv()

#R data set
data<-readRDS()

#potential to run Python program in order to download excel files again here
#system('python /home/rstudio/projects/comp-2015/data/rawdat/00-pull-historical-load-data.py')


#-----------------------------------------------------------------------------#
#
# Processing
#
#-----------------------------------------------------------------------------#

#set the raw data as the current directory
setwd("/home/jonfar/Projects/comp-2015/data/rawdat")

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

#go from wide to long
load.long <- melt(load.data, id=c("DATE", "COMP")) %>%
  rename(hour = variable, load = value) %>%
  mutate(tindx = mdy_h(paste(DATE, substr(hour, 3, 4)))-duration(1,"hours"),
         hindx = hour(tindx),
         dindx = as.Date(tindx),
         mindx = month(tindx)) %>%
  select(tindx, hindx, dindx, mindx, load)

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
# Outputs
#
#-----------------------------------------------------------------------------#

write.csv()
writeRDS()

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#