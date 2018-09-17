import logging
import ssl
from http.server import BaseHTTPRequestHandler, HTTPServer

DEFAULT_PORT = 8443


class SOHandler(BaseHTTPRequestHandler):

    def __init__(self, request, client_address, server):
        self.response_on_get = self._read_on_get_response()
        super().__init__(request, client_address, server)

    def do_POST(self):
        logging.info('POST called')
        self.send_response(200)
        self._set_headers()

        self.wfile.write(self.response_on_get.encode("utf-8"))
        return

    def _set_headers(self):
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

    @staticmethod
    def _read_on_get_response():
        with open('so_get_response.json', 'r') as file:
            return file.read()


if __name__ == '__main__':
    logging.basicConfig(filename='output.log', level=logging.INFO)
    SOHandler.protocol_version = "HTTP/1.0"

    httpd = HTTPServer(('', DEFAULT_PORT), SOHandler)
    logging.info("serving on: " + str(httpd.socket.getsockname()))
    httpd.socket = ssl.wrap_socket(httpd.socket, server_side=True, certfile='cert.pem', keyfile='key.pem')
    httpd.serve_forever()
