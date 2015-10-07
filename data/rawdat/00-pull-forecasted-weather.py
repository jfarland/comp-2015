
import sys, csv, json, urllib2, requests

f = urllib2.urlopen('http://api.wunderground.com/api/c9be88eb723364fc/hourly10day/q/VA/Richmond.json')

json_string = f.read()
parsed_json = json.loads(json_string)

#look at the top level
parsed_json.keys()

#check to make sure it's a dictionary
type(parsed_json[u'hourly_forecast'])

#look at the top obs
parsed_json[u'hourly_forecast'][:20]

#we could output the json file as text now
with open('weather-forecasts.txt', 'w') as outfile:
  json.dump(parsed_json, outfile)


