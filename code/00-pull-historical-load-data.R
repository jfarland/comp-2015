library(gdata)
library(RCurl)
library(XML)
library(XLConnect)


# References
# http://gastonsanchez.com/work/webdata/getting_web_data_r2_reading_files.pdf

# URL locations
# http://www.pjm.com/pub/operations/hist-meter-load/2015-hourly-loads.xls
# http://www.pjm.com/pub/operations/hist-meter-load/2014-hourly-loads.xls



#using GDATA 
load15_home = "http://www.pjm.com/pub/operations/hist-meter-load/2015-hourly-loads.xls"
load14_home = "http://www.pjm.com/pub/operations/hist-meter-load/2014-hourly-loads.xls"

#sheetCount(data_home)

perl = "C:/Users/jonfar/AppData/Local/Programs/Git/bin/perl.exe"

write.csv(read.xls(data_home, sheet = 9, perl=perl), file="C:/Users/jonfar/Documents/Research/comp-2015/data/rawdat/load15.csv") 


dat = read.xls(load15_home, sheet = 9, perl=perl)

head(data)
summary(data)
names(data)

