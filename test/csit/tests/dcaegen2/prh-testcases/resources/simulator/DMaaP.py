import BaseHTTPServer
import re
import sys

from robot.api import logger

posted_event_from_prh = 'Empty'
received_event_to_get_method = 'Empty'

class DMaaPHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_PUT(self):
        if re.search('/set_get_event', self.path):
            global received_event_to_get_method
            posted_event_from_prh = 'Empty'
            content_length = int(self.headers['Content-Length'])
            received_event_to_get_method = self.rfile.read(content_length)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
        return

    def do_POST(self):
        if re.search('/events/pnfReady', self.path):
            global posted_event_from_prh
            content_length = int(self.headers['Content-Length'])
            posted_event_from_prh = self.rfile.read(content_length)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
        return

    def do_GET(self):
        if re.search('/events/unauthenticated.SEC_OTHER_OUTPUT/OpenDcae-c12/c12', self.path):
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(received_event_to_get_method)
            self.wfile.close()
        elif re.search('/events/pnfReady', self.path):
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(posted_event_from_prh)
            self.wfile.close()
        else:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write('GET else')
            self.wfile.close()
            
        return

def _main_ (HandlerClass = DMaaPHandler, ServerClass = BaseHTTPServer.HTTPServer, protocol="HTTP/1.0"):

    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 2222

    server_address = ('', port)

    HandlerClass.protocol_version = protocol
    httpd = ServerClass(server_address, HandlerClass)

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    httpd.serve_forever()

if __name__ == '__main__':
    _main_()
