'''
Created on Apr 27, 2018

@author: mwagner9
'''

import os

def GetEnvironmentVariable(envVarstr):
    return os.environ.get(envVarstr)

DMaaPHttpServerThread = None
DMaaPHTTPD = None
DMaaPIsRobotRun = False

AAIHttpServerThread = None
AAIHTTPD = None
AAIIsRobotRun = False
