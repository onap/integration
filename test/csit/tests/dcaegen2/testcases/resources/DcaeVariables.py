import os


def get_environment_variable(env_varstr):
    return os.environ.get(env_varstr)


DCAE_HEALTH_CHECK_URL = "http://135.205.228.129:8500"
DCAE_HEALTH_CHECK_URL1 = "http://135.205.228.170:8500"

CommonEventSchemaV5 = get_environment_variable('WORKSPACE') + "/test/csit/tests/dcaegen2/testcases/assets/json_events/CommonEventFormat_28.3.json"

HttpServerThread = None
HTTPD = None
VESEventQ = None
IsRobotRun = False

