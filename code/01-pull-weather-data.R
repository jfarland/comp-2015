

library(weatherData)
library(dplyr)

View(USAirportWeatherStations)

VA_stat <- subset(USAirportWeatherStations, State=="VA")
View(VA_stat)

library(ggplot2)
library(rworldmap)

newmap<- getMap(resolution="low")
plot(newmap, xlim=c(-81,-70),ylim=c(30,40))
points(VA_stat$Lon, VA_stat$Lat, col ="red")

# library(ggmap)
# map <- get_map(location= "Europe")
# ggmap(map)

#pull weather data

beg <- as.Date('2010/01/01',format= "%Y/%m/%d")
end <- as.Date('2015/10/05',format= "%Y/%m/%d")

s <- seq(beg, to = end, by = 'days')

wx_df <- list()

#wx_df <- getDetailedWeather("RIC", "2015-01-01", opt_all_columns = T)

# for ( i in seq_along(s))
# {
#   print(i)
#   print(s[i])
#   wx_df[[i]]<-getDetailedWeather("RIC", s[i], opt_all_columns = T)
#   wx_df[[i]]$Wind_SpeedMPH[wx_df[[i]]$Wind_SpeedMPH %in% ("Calm")] = 0
#   wx_df[[i]]$Wind_SpeedMPH = as.numeric(wx_df[[i]]$Wind_SpeedMPH)
# }

for ( i in seq_along(s))
{
  print(i)
  print(s[i])
  wx_df[[i]]<-getDetailedWeather("RIC", s[i], opt_temperature_columns = T)
  }


#unpack the list
wx_df2 <- bind_rows(wx_df)



View(wx_df)
