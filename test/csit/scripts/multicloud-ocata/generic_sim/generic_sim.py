import web
import web.webapi
import json
import logging

from subprocess import Popen, PIPE
from xml.dom import minidom

urls = (
  '/healthcheck','healthcheck'
)

myhelp = {"/sim/help":"provides help"}
myok = {"ok":"ok"}
json_data={}

replydir = "./responses/"

formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
def setup_logger(name, log_file, level=logging.INFO):
    handler = logging.FileHandler(log_file)
    handler.setFormatter(formatter)

    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.addHandler(handler)

    return logger

class healthcheck:
    def GET(self):
        print ("------------------------------------------------------")
        replyfile = "healthcheck.json"
        fullreply = replydir + replyfile
        trid=web.ctx.env.get('X_TRANSACTIONID','111111')
        #print ("X-TransactionId : {}".format(trid))
        logger = setup_logger('healthcheck', '/generic_sim_logs/healthcheck.log')
        logger.info('{}'.format(web.ctx.fullpath))
        print ("this is the context : {}".format(web.ctx.fullpath))
        with open(fullreply) as json_file:
            json_data = json.load(json_file)
            print(json_data)

        web.header('Content-Type', 'application/json')
        web.header('X-TransactionId', trid)
        return json.dumps(json_data)

if __name__ == "__main__":
    app = web.application(urls, globals())
    app.run()