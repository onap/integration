from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
import re
import sys

pnfs = 'Empty'


class AAIHandler(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_pnfs', self.path):
            global pnfs
            content_length = int(self.headers['Content-Length'])
            pnfs = self.rfile.read(content_length)
            _header_200_and_json(self)
            
        return

    def do_PATCH(self):
        pnfs_name = '/aai/v12/network/pnfs/pnf/' + pnfs.decode()
        if re.search('wrong_aai_record', self.path):
            self.send_response(400)
            self.end_headers()
        elif re.search(pnfs_name, self.path):
            self.send_response(200)
            self.end_headers()
            
        return


def _header_200_and_json(self):
    self.send_response(200)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()


def _main_(handler_class=AAIHandler, server_class=HTTPServer, protocol="HTTP/1.0"):

    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 3333

    server_address = ('', port)

    handler_class.protocol_version = protocol
    httpd = server_class(server_address, handler_class)

    sa = httpd.socket.getsockname()
    print("Serving HTTP on", sa[0], "port", sa[1], "...")
    httpd.serve_forever()


if __name__ == '__main__':
    _main_()
