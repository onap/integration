"""
This simulator is based on the simulator used in OOF to simulate AAI [1].
It is used to simulate the OOF homing response. During CSIT testing of SO HPA,
run this simulator and replace the Chef config SNIRO endpoint in [2] with
localhost so that SO now talks to the simulator and we can control the OOF
Homing solution.

[1] - https://git.onap.org/optf/has/tree/conductor/conductor/tests/functional/simulators/aaisim
[2] - https://git.onap.org/integration/tree/test/csit/scripts/so/chef-config/mso-docker.json#n170
"""

import web
import web.webapi
import json
import logging

from subprocess import Popen, PIPE
from xml.dom import minidom

urls = (
  '/healthcheck','healthcheck',
  '/api/oof/v1/placement', 'oof_homing_solution',
  # Change to real OpenStack endpoint.
  '/multicloud_endpoint', 'multicloud_endpoint',
)

json_data={}

replydir = "./responses/"

formatter = logging.Formatter('%(message)s')
def setup_logger(name, log_file, level=logging.INFO):
    handler = logging.FileHandler(log_file)
    handler.setFormatter(formatter)

    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.addHandler(handler)

    return logger

class healthcheck:
    def GET(self):
        replyfile = "healthcheck.json"
        fullreply = replydir + replyfile
        trid = web.ctx.env.get('X_TRANSACTIONID','111111')

        logger = setup_logger('healthcheck', '/generic_sim_logs/healthcheck.log')
        logger.info('{}'.format(web.ctx.fullpath))

        with open(fullreply) as json_file:
            json_data = json.load(json_file)

        web.header('Content-Type', 'application/json')
        web.header('X-TransactionId', trid)
        return json.dumps(json_data)

class oof_homing_solution:
    def POST(self):
        replyfile = "oof_homing_solution.json"
        fullreply = replydir + replyfile
        trid=web.ctx.env.get('X_TRANSACTIONID','111111')

        logger = setup_logger('request_to_oof', '/generic_sim_logs/request_to_oof.log')
        logger.info('{}'.format(web.ctx.env.get('wsgi.input').read())) # Logging the POST body which was sent.

        print ("this is the context : {}".format(web.ctx.fullpath))
        with open(fullreply) as json_file:
            json_data = json.load(json_file)

        web.header('Content-Type', 'application/json')
        web.header('X-TransactionId', trid)
        return json.dumps(json_data)

class multicloud_endpoint:
    def GET(self):
        print ("------------------------------------------------------")
        replyfile = "multicloud_response.json"
        fullreply = replydir + replyfile
        trid=web.ctx.env.get('X_TRANSACTIONID','111111')

        logger = setup_logger('homing_solution', '/generic_sim_logs/multicloud_endpoint.log')
        logger.info('{}'.format(web.ctx.fullpath))

        with open(fullreply) as json_file:
            json_data = json.load(json_file)

        web.header('Content-Type', 'application/json')
        web.header('X-TransactionId', trid)
        return json.dumps(json_data)

    def POST(self):
        # TODO: Log whatever SO calls here using logger.
        pass

if __name__ == "__main__":
    app = web.application(urls, globals())
    app.run()
