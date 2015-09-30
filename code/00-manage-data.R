

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
library("dplyr")


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


#-----------------------------------------------------------------------------#
#
# Processing
#
#-----------------------------------------------------------------------------#

library(gdata)
library(dplyr)

#set the raw data as the current directory
setwd("/home/jonfar/Projects/comp-2015/data/rawdat")

#Read in only the dominion tab of the excel spreadsheets
load11 <- read.xls("load11.xls", sheet=22)
load12 <- read.xls("load12.xls", sheet=22)
load13 <- read.xls("load13.xls", sheet=22)
load14 <- read.xls("load14.xls", sheet=22)
load15 <- read.xls("load15.xls", sheet=22)

load.data=rbind(load11, load12, load13, load14)#, load15)

#for (i in 11:15){
#  load.data[[i-10]] <- read.xls(paste("load", i, ".xls", sep=""), sheet = 22)
#}

#do.call(rbind, load.data)

#load.data_ul <- unlist(load.data)



#quick checks
#check1<-stopifnot(load11$comp == "DOM")
summary(load11)




#-----------------------------------------------------------------------------#
#
# Outputs
#
#-----------------------------------------------------------------------------#


write.csv()
writeRDS()

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#