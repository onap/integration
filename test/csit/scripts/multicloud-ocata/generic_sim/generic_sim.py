# Copyright 2018 Intel Corporation, Inc
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import web
import web.webapi
import json
import logging

from subprocess import Popen, PIPE
from xml.dom import minidom

urls = (
  '/healthcheck','healthcheck'
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
            print(json_data)

        web.header('Content-Type', 'application/json')
        web.header('X-TransactionId', trid)
        return json.dumps(json_data)

if __name__ == "__main__":
    app = web.application(urls, globals())
    app.run()