from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
import re
import sys

posted_event_from_prh = b'Empty'
received_event_to_get_method = 'Empty'


class DMaaPHandler(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_get_event', self.path):
            global received_event_to_get_method
            content_length = int(self.headers['Content-Length'])
            received_event_to_get_method = self.rfile.read(content_length)
            _header_200_and_json(self)
            
        return

    def do_POST(self):
        if re.search('/events/unauthenticated.PNF_READY', self.path):
            global posted_event_from_prh
            content_length = int(self.headers['Content-Length'])
            posted_event_from_prh = self.rfile.read(content_length)
            _header_200_and_json(self)
            
        return

    def do_GET(self):
        if re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12', self.path):
            _header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)
        elif re.search('/events/pnfReady', self.path):
            _header_200_and_json(self)
            self.wfile.write(posted_event_from_prh)

        return


def _header_200_and_json(self):
    self.send_response(200)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()


def _main_(handler_class=DMaaPHandler, server_class=HTTPServer, protocol="HTTP/1.0"):

    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 2222

    server_address = ('', port)

    handler_class.protocol_version = protocol
    httpd = server_class(server_address, handler_class)

    sa = httpd.socket.getsockname()
    print("Serving HTTP on", sa[0], "port", sa[1], "...")
    httpd.serve_forever()


if __name__ == '__main__':
    _main_()
