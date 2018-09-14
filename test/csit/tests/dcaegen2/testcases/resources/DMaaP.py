'''
Created on Aug 15, 2017

@author: sw6830
'''
import os
import posixpath
import BaseHTTPServer
import urllib
import urlparse
import cgi
import sys
import shutil
import mimetypes
from jsonschema import validate
import jsonschema
import json
import DcaeVariables
import SimpleHTTPServer
from robot.api import logger


try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO

EvtSchema = None
DMaaPHttpd = None


def clean_up_event():
    sz = DcaeVariables.VESEventQ.qsize()
    for i in range(sz):
        try:
            self.evtQueue.get_nowait()
        except:
            pass


def enque_event(evt):
    if DcaeVariables.VESEventQ is not None:
        try:
            DcaeVariables.VESEventQ.put(evt)
            if DcaeVariables.IsRobotRun:
                logger.console("DMaaP Event enqued - size=" + str(len(evt)))
            else:
                print ("DMaaP Event enqueued - size=" + str(len(evt)))
            return True
        except Exception as e:
            print (str(e))
            return False
    return False


def deque_event(wait_sec=25):
    if DcaeVariables.IsRobotRun:
        logger.console("Enter DequeEvent")
    try:
        evt = DcaeVariables.VESEventQ.get(True, wait_sec)
        if DcaeVariables.IsRobotRun:
            logger.console("DMaaP Event dequeued - size=" + str(len(evt)))
        else:
            print("DMaaP Event dequeued - size=" + str(len(evt)))
        return evt
    except Exception as e:
        if DcaeVariables.IsRobotRun:
            logger.console(str(e))
            logger.console("DMaaP Event dequeue timeout")
        else:
            print("DMaaP Event dequeue timeout")
        return None


class DMaaPHandler(BaseHTTPServer.BaseHTTPRequestHandler):
      
    def do_PUT(self):
        self.send_response(405)
        return
        
    def do_POST(self):
        
        resp_code = 0
        # Parse the form data posted
        '''
        form = cgi.FieldStorage(
            fp=self.rfile, 
            headers=self.headers,
            environ={'REQUEST_METHOD':'POST',
                     'CONTENT_TYPE':self.headers['Content-Type'],
                     })
        
        
        form = cgi.FieldStorage(
        fp=self.rfile,
        headers=self.headers,
        environ={"REQUEST_METHOD": "POST"})

        for item in form.list:
            print "%s=%s" % (item.name, item.value)
            
        '''
        
        if 'POST' not in self.requestline:
            resp_code = 405
            
        '''
        if resp_code == 0:
            if '/eventlistener/v5' not in self.requestline and '/eventlistener/v5/eventBatch' not in self.requestline and \
                        '/eventlistener/v5/clientThrottlingState' not in self.requestline:
                resp_code = 404
         
        
        if resp_code == 0:
            if 'Y29uc29sZTpaakprWWpsbE1qbGpNVEkyTTJJeg==' not in str(self.headers):
                resp_code = 401
        '''  
        
        if resp_code == 0:
            content_len = int(self.headers.getheader('content-length', 0))
            post_body = self.rfile.read(content_len)
            
            if DcaeVariables.IsRobotRun:
                logger.console("\n" + "DMaaP Receive Event:\n" + post_body)
            else:
                print("\n" + "DMaaP Receive Event:")
                print (post_body)
            
            indx = post_body.index("{")
            if indx != 0:
                post_body = post_body[indx:]
            
            if not enque_event(post_body):
                print "enque event fails"
                   
            global EvtSchema
            try:
                if EvtSchema is None:
                    with open(DcaeVariables.CommonEventSchemaV5) as opened_file:
                        EvtSchema = json.load(opened_file)
                decoded_body = json.loads(post_body)
                jsonschema.validate(decoded_body, EvtSchema)
            except:
                resp_code = 400
        
        # Begin the response
        if not DcaeVariables.IsRobotRun:
            print ("Response Message:")
        
        '''
        {
          "200" : {
            "description" : "Success",
            "schema" : {
              "$ref" : "#/definitions/DR_Pub"
            }
        }
        
        rspStr = "{'responses' : {'200' : {'description' : 'Success'}}}"
        rspStr1 = "{'count': 1, 'serverTimeMs': 3}"

        '''
        
        if resp_code == 0:
            if 'clientThrottlingState' in self.requestline:
                self.send_response(204)
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                # self.wfile.write("{'responses' : {'200' : {'description' : 'Success'}}}")
                self.wfile.write("{'count': 1, 'serverTimeMs': 3}")
                self.wfile.close()
        else:
            self.send_response(resp_code)
        
        '''
        self.end_headers()
        self.wfile.write('Client: %s\n' % str(self.client_address))
        self.wfile.write('User-agent: %s\n' % str(self.headers['user-agent']))
        self.wfile.write('Path: %s\n' % self.path)
        self.wfile.write('Form data:\n')
        self.wfile.close()

        # Echo back information about what was posted in the form
        for field in form.keys():
            field_item = form[field]
            if field_item.filename:
                # The field contains an uploaded file
                file_data = field_item.file.read()
                file_len = len(file_data)
                del file_data
                self.wfile.write('\tUploaded %s as "%s" (%d bytes)\n' % \
                        (field, field_item.filename, file_len))
            else:
                # Regular form value
                self.wfile.write('\t%s=%s\n' % (field, form[field].value))
        '''
        return

    def do_GET(self):
        """Serve a GET request."""
        f = self.send_head()
        if f:
            try:
                self.copyfile(f, self.wfile)
            finally:
                f.close()

    def do_HEAD(self):
        """Serve a HEAD request."""
        f = self.send_head()
        if f:
            f.close()

    def send_head(self):
        """Common code for GET and HEAD commands.

        This sends the response code and MIME headers.

        Return value is either a file object (which has to be copied
        to the outputfile by the caller unless the command was HEAD,
        and must be closed by the caller under all circumstances), or
        None, in which case the caller has nothing further to do.

        """
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            parts = urlparse.urlsplit(self.path)
            if not parts.path.endswith('/'):
                # redirect browser - doing basically what apache does
                self.send_response(301)
                new_parts = (parts[0], parts[1], parts[2] + '/',
                             parts[3], parts[4])
                new_url = urlparse.urlunsplit(new_parts)
                self.send_header("Location", new_url)
                self.end_headers()
                return None
            for index in "index.html", "index.htm":
                index = os.path.join(path, index)
                if os.path.exists(index):
                    path = index
                    break
            else:
                return self.list_directory(path)
        ctype = self.guess_type(path)
        try:
            # Always read in binary mode. Opening files in text mode may cause
            # newline translations, making the actual size of the content
            # transmitted *less* than the content-length!
            f = open(path, 'rb')
        except IOError:
            self.send_error(404, "File not found")
            return None
        try:
            self.send_response(200)
            self.send_header("Content-type", ctype)
            fs = os.fstat(f.fileno())
            self.send_header("Content-Length", str(fs[6]))
            self.send_header("Last-Modified", self.date_time_string(fs.st_mtime))
            self.end_headers()
            return f
        except:
            f.close()
            raise

    def list_directory(self, path):
        """Helper to produce a directory listing (absent index.html).

        Return value is either a file object, or None (indicating an
        error).  In either case, the headers are sent, making the
        interface the same as for send_head().

        """
        try:
            list_dir = os.listdir(path)
        except os.error:
            self.send_error(404, "No permission to list directory")
            return None
        list_dir.sort(key=lambda a: a.lower())
        f = StringIO()
        displaypath = cgi.escape(urllib.unquote(self.path))
        f.write('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">')
        f.write("<html>\n<title>Directory listing for %s</title>\n" % displaypath)
        f.write("<body>\n<h2>Directory listing for %s</h2>\n" % displaypath)
        f.write("<hr>\n<ul>\n")
        for name in list_dir:
            fullname = os.path.join(path, name)
            displayname = linkname = name
            # Append / for directories or @ for symbolic links
            if os.path.isdir(fullname):
                displayname = name + "/"
                linkname = name + "/"
            if os.path.islink(fullname):
                displayname = name + "@"
                # Note: a link to a directory displays with @ and links with /
            f.write('<li><a href="%s">%s</a>\n'
                    % (urllib.quote(linkname), cgi.escape(displayname)))
        f.write("</ul>\n<hr>\n</body>\n</html>\n")
        length = f.tell()
        f.seek(0)
        self.send_response(200)
        encoding = sys.getfilesystemencoding()
        self.send_header("Content-type", "text/html; charset=%s" % encoding)
        self.send_header("Content-Length", str(length))
        self.end_headers()
        return f

    @staticmethod
    def translate_path(path):
        """Translate a /-separated PATH to the local filename syntax.

        Components that mean special things to the local file system
        (e.g. drive or directory names) are ignored.  (XXX They should
        probably be diagnosed.)

        """
        # abandon query parameters
        path = path.split('?', 1)[0]
        path = path.split('#', 1)[0]
        # Don't forget explicit trailing slash when normalizing. Issue17324
        trailing_slash = path.rstrip().endswith('/')
        path = posixpath.normpath(urllib.unquote(path))
        words = path.split('/')
        words = filter(None, words)
        path = os.getcwd()
        for word in words:
            if os.path.dirname(word) or word in (os.curdir, os.pardir):
                # Ignore components that are not a simple file/directory name
                continue
            path = os.path.join(path, word)
        if trailing_slash:
            path += '/'
        return path

    @staticmethod
    def copyfile(source, outputfile):
        """Copy all data between two file objects.

        The SOURCE argument is a file object open for reading
        (or anything with a read() method) and the DESTINATION
        argument is a file object open for writing (or
        anything with a write() method).

        The only reason for overriding this would be to change
        the block size or perhaps to replace newlines by CRLF
        -- note however that this the default server uses this
        to copy binary data as well.

        """
        shutil.copyfileobj(source, outputfile)

    def guess_type(self, path):
        """Guess the type of a file.

        Argument is a PATH (a filename).

        Return value is a string of the form type/subtype,
        usable for a MIME Content-type header.

        The default implementation looks the file's extension
        up in the table self.extensions_map, using application/octet-stream
        as a default; however it would be permissible (if
        slow) to look inside the data to make a better guess.

        """

        base, ext = posixpath.splitext(path)
        if ext in self.extensions_map:
            return self.extensions_map[ext]
        ext = ext.lower()
        if ext in self.extensions_map:
            return self.extensions_map[ext]
        else:
            return self.extensions_map['']

    if not mimetypes.inited:
        mimetypes.init()  # try to read system mime.types
    extensions_map = mimetypes.types_map.copy()
    extensions_map.update({
        '': 'application/octet-stream',  # Default
        '.py': 'text/plain',
        '.c': 'text/plain',
        '.h': 'text/plain',
        })


def test(handler_class=DMaaPHandler, server_class=BaseHTTPServer.HTTPServer, protocol="HTTP/1.0", port=3904):
    print "Load event schema file: " + DcaeVariables.CommonEventSchemaV5
    with open(DcaeVariables.CommonEventSchemaV5) as opened_file:
        global EvtSchema
        EvtSchema = json.load(opened_file)
        
    server_address = ('', port)

    handler_class.protocol_version = protocol
    httpd = server_class(server_address, handler_class)
    
    global DMaaPHttpd
    DMaaPHttpd = httpd
    DcaeVariables.HTTPD = httpd

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    # httpd.serve_forever()


def _main_(handler_class=DMaaPHandler, server_class=BaseHTTPServer.HTTPServer, protocol="HTTP/1.0"):
    
    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 3904
    
    print "Load event schema file: " + DcaeVariables.CommonEventSchemaV5
    with open(DcaeVariables.CommonEventSchemaV5) as opened_file:
        global EvtSchema
        EvtSchema = json.load(opened_file)
        
    server_address = ('', port)

    handler_class.protocol_version = protocol
    httpd = server_class(server_address, handler_class)

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    httpd.serve_forever()


if __name__ == '__main__':
    _main_()
