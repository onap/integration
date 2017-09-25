
import os, time

def GetEnvironmentVariable(envVarstr):
    return os.environ.get(envVarstr)

DCAE_HEALTH_CHECK_URL = "http://135.205.228.129:8500"
DCAE_HEALTH_CHECK_URL1 = "http://135.205.228.170:8500"

CommonEventSchemaV5  = GetEnvironmentVariable('WORKSPACE') + "/test/csit/tests/dcaegen2/testcases/assets/json_events/CommonEventFormat_28.3.json"

HttpServerThread = None
HTTPD = None
VESEventQ = None
IsRobotRun = False

