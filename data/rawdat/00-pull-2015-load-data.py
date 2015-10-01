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


