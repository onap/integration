import BaseHTTPServer
import json
import posixpath
import sys
import urllib
from Queue import Queue

import jsonschema
from robot.api import logger

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO

CommonEventSchemaV5 = "./CommonEventFormat_28.3.json"
EvtSchema = None
EventQueue = {"defaultTopic": Queue()}


def cleanUpEvent(topic="defaultTopic"):
    try:
        EventQueue.get(topic).empty()
    except Exception as e:
        logger.console(str(e))
        logger.console("DMaaP Event enqueue failed")


def enqueEvent(evt, topic="defaultTopic"):
    if topic not in EventQueue.keys():
        EventQueue.update({topic: Queue()})

    try:
        EventQueue.get(topic).put(evt)
        logger.console("DMaaP Event enqued - size=" + str(len(evt)))
        return True
    except Exception as e:
        logger.console(str(e))
        logger.console("DMaaP Event enqueue failed")
        return False


def dequeEvent(topic="defaultTopic", waitSec=10):
    try:
        evt = EventQueue.get(topic).get(True, waitSec)
        logger.console("DMaaP Event dequeued - size=" + str(len(evt)))
        return evt
    except Exception as e:
        logger.console(str(e))
        logger.console("DMaaP Event dequeue failed")
        return None


class DMaaPHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def do_PUT(self):
        self.send_response(405)
        return

    def do_PATCH(self):
        self.send_response(200)
        return
        
    def do_POST(self):
        
        respCode = 0

        if 'POST' not in self.requestline:
            respCode = 405
        
        if respCode == 0:
            content_len = int(self.headers.getheader('content-length', 0))
            post_body = self.rfile.read(content_len)

            logger.console("DMaaP Receive Event:\n" + post_body)
            
            indx = post_body.index("{")
            if indx != 0:
                post_body = post_body[indx:]

            topic = self.getTopicName(self.path)

            if topic is not None:
                logger.console("DMaaP Topic Name: " + topic)
                if enqueEvent(post_body, topic) == False:
                    print "enque event fails"
                   
            global EvtSchema
            try:
                if EvtSchema is None:
                    with open(CommonEventSchemaV5) as file:
                        EvtSchema = json.load(file)
                decoded_body = json.loads(post_body)
                jsonschema.validate(decoded_body, EvtSchema)
            except:
                respCode = 400
        
        if respCode == 0:
            if 'clientThrottlingState' in self.requestline:
                self.send_response(204)
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write("{\"count\": 1, \"serverTimeMs\": 3}")
                self.wfile.close()
        else:
            self.send_response(respCode)

        return

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(dequeEvent(self.getTopicName(self.path)))
        self.wfile.close()

        return

    def getTopicName(self, path):
        # abandon query parameters
        path = path.split('?',1)[0]
        path = path.split('#',1)[0]

        path = posixpath.normpath(urllib.unquote(path))
        parts = filter(None, path.split('/'))

        if len(parts) > 1 and parts[0] == "events":
            return str(parts[1])
        else:
            return None

def _main_ (HandlerClass = DMaaPHandler,
         ServerClass = BaseHTTPServer.HTTPServer, protocol="HTTP/1.0"):
    
    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 2222
    
    print "Load event schema file: " + CommonEventSchemaV5
    with open(CommonEventSchemaV5) as file:
        global EvtSchema
        EvtSchema = json.load(file)
        
    server_address = ('', port)

    HandlerClass.protocol_version = protocol
    httpd = ServerClass(server_address, HandlerClass)

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    httpd.serve_forever()
    
if __name__ == '__main__':
    _main_()