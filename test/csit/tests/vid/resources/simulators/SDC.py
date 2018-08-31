import ssl
from http.server import BaseHTTPRequestHandler, HTTPServer

from sys import argv

DEFAULT_PORT = 8443


class SDCHandler(BaseHTTPRequestHandler):

    def __init__(self, request, client_address, server):
        self.response_on_get = self._read_on_get_response()
        super().__init__(request, client_address, server)

    def do_GET(self):
        self.send_response(200)
        self._set_headers()

        self.wfile.write(self.response_on_get.encode("utf-8"))
        return

    def _set_headers(self):
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

    @staticmethod
    def _read_on_get_response():
        with open('sdc_get_response.json', 'r') as file:
            return file.read()


if __name__ == '__main__':
    SDCHandler.protocol_version = "HTTP/1.1"

    httpd = HTTPServer(('', DEFAULT_PORT), SDCHandler)
    httpd.socket = ssl.wrap_socket(httpd.socket, server_side=True, certfile='cert.pem', keyfile='key.pem')
    httpd.serve_forever()
