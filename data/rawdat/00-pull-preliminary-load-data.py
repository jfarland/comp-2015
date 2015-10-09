# -*- coding: utf-8 -*-
"""
Created on Wed Oct 7th 2015

@author: jonfar
"""

#!/usr/bin/env python
# -*- coding: utf-8 -*-


import requests
import urllib

prelim1007 = "http://www.pjm.com/pub/market_system_data/system/hourly_prelim_loads/daily/20151007_dailyload.csv"
urllib.urlretrieve(prelim1007, "20151007_dailyload.csv")

prelim1006 = "http://www.pjm.com/pub/market_system_data/system/hourly_prelim_loads/daily/20151006_dailyload.csv"
urllib.urlretrieve(prelim1006, "20151006_dailyload.csv")

prelim1005 = "http://www.pjm.com/pub/market_system_data/system/hourly_prelim_loads/daily/20151005_dailyload.csv"
urllib.urlretrieve(prelim1005, "20151005_dailyload.csv")

prelim1004 = "http://www.pjm.com/pub/market_system_data/system/hourly_prelim_loads/daily/20151004_dailyload.csv"
urllib.urlretrieve(prelim1004, "20151004_dailyload.csv")

prelim1003 = "http://www.pjm.com/pub/market_system_data/system/hourly_prelim_loads/daily/20151003_dailyload.csv"
urllib.urlretrieve(prelim1003, "20151003_dailyload.csv")

prelim1002 = "http://www.pjm.com/pub/market_system_data/system/hourly_prelim_loads/daily/20151002_dailyload.csv"
urllib.urlretrieve(prelim1002, "20151002_dailyload.csv")


