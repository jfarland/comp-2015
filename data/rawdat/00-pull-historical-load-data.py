# -*- coding: utf-8 -*-
"""
Created on Wed Sep 20 2015

@author: jonfar
"""

#!/usr/bin/env python
# -*- coding: utf-8 -*-


import requests
import urllib

load15 = "http://www.pjm.com/pub/operations/hist-meter-load/2015-hourly-loads.xls"
urllib.urlretrieve(load15, "load15.xls")

load14 = "http://www.pjm.com/pub/operations/hist-meter-load/2014-hourly-loads.xls"
urllib.urlretrieve(load14, "load14.xls")

load13 = "http://www.pjm.com/pub/operations/hist-meter-load/2013-hourly-loads.xls"
urllib.urlretrieve(load13, "load13.xls")

load12 = "http://www.pjm.com/pub/operations/hist-meter-load/2012-hourly-loads.xls"
urllib.urlretrieve(load12, "load12.xls")

load11 = "http://www.pjm.com/pub/operations/hist-meter-load/2011-hourly-loads.xls"
urllib.urlretrieve(load11, "load11.xls")

