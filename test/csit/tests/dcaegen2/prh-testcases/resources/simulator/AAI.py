import BaseHTTPServer
import re
import sys

from robot.api import logger

pnfs = 'Empty'

class AAIHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_PUT(self):
        if re.search('/set_pnfs', self.path):
            global pnfs
            content_length = int(self.headers['Content-Length'])
            pnfs = self.rfile.read(content_length)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
        return

    def do_PATCH(self):
        pnfs_name = '/aai/v12/network/pnfs/pnf/' + pnfs
        if re.search('wrong_aai_record', self.path):
            self.send_response(400)
            self.end_headers()
        elif re.search(pnfs_name, self.path):
            self.send_response(200)
            self.end_headers()
            
        return

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write('GET')
        self.wfile.close()
        
        return

def _main_ (HandlerClass = AAIHandler, ServerClass = BaseHTTPServer.HTTPServer, protocol="HTTP/1.0"):

    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 3333

    server_address = ('', port)

    HandlerClass.protocol_version = protocol
    httpd = ServerClass(server_address, HandlerClass)

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    httpd.serve_forever()

if __name__ == '__main__':
    _main_()
