from  BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
import re
import json
import base64
import urlparse

with open("DefinedNRMFunction.json",'r') as f:
    jsonFile = json.loads(f.read())
SupportingFunctionList = jsonFile["NRMFunction"]

with open("UserInfo.json",'r') as f:
    UserFile = json.loads(f.read())

with open("ConfigInfo.json",'r') as f:
    ConfigFile = json.loads(f.read())

with open("preSetMOI.json",'r') as f:
    Cretaed_MOIs = json.loads(f.read())
Cretaed_MOIs_list = Cretaed_MOIs['preSetMOI']

ipAddress = ConfigFile["ipAddress"]
portNumber = ConfigFile["portNumber"]
prefix = ConfigFile["prefix"]

username = UserFile['userName']
password = UserFile['password']
Auth_str = username+":"+password
print(Auth_str)
base64string = base64.encodestring(Auth_str)[:-1]
authheader =  "Basic %s" % base64string.decode('utf-8')
print(authheader)

class ServerHTTP(BaseHTTPRequestHandler):
    def do_GET(self):
        path = self.path
        print("\n**************************** NEW GET REQUEST ********************************")
        request = urlparse.urlparse(path)
        print("the PATH of the received GET request:" + request.path)
        pathlist = request.path.split('/')
        if "/" + pathlist[1] + "/"+ pathlist[2] == prefix:
            prefix_check = True
        else:
            prefix_check = False
        className = pathlist[3]
        idName = pathlist[4]
        response = {}
        query_params = urlparse.parse_qs(request.query)
        if self.headers['Authorization'] == authheader and prefix_check is True:
            if className in SupportingFunctionList:
                try:
                    print("the value of the scope : "+ str(query_params['scope']))
                    print("the value of the filter : "+ str(query_params['filter']))
                    print("the value of the fields : "+ str(query_params['fields']))
                except:
                    print("the request body doesn't follow the standard format")
                    response['error'] = "the request body doesn't follow the standard format"
                    print("Fail to get MOI object: "+'/' +className+'/'+idName)
                    self.send_response(406)
                else:
                    find_moi = False
                    for MOI in Cretaed_MOIs_list:
                        if (idName == MOI['id'] and className == MOI['class']):
                            find_moi = True
                            try:
                                attributes = {}
                                for field in query_params['fields']:
                                    attributes[field] = MOI['attributes'][field]
                            except Exception as e:
                                print("the createed MOI doesn't contain the required attribute")
                                response['error'] = "the createed MOI doesn't contain the required attribute"
                                print("Fail to get MOI object: "+'/' +className+'/'+idName)
                                self.send_response(406)
                            else:
                                print("Successfully get MOI object: "+ className+'_'+idName)
                                response = {"data":[{"href":"/"+className+"/"+idName,"class":className,"id":idName,"attributes":attributes}]}
                                self.send_response(200)
                    if (find_moi is False):
                        response['error'] = {"errorInfo":"MOI does not exist"}
                        print("Fail to get MOI object: "+'/' +className+'/'+idName)
                        self.send_response(406)
            else:
                response['error'] = {"errorInfo":"MOI class not support"}
                print("Fail to get MOI object: "+'/' +className+'/'+idName)
                self.send_response(406)
        else:
            self.send_response(401)
            if prefix_check is True:
                response['error'] = {"errorInfo":"not Authorized"}
            else:
                response['error'] = {"errorInfo":"wrong prefix"}
        self.send_header("Content-type","application/json")
        self.end_headers()
        buf = json.dumps(response)
        self.wfile.write(buf)

    def do_PATCH(self):
        path = self.path
        print("\n**************************** NEW PATCH REQUEST ********************************")
        request = urlparse.urlparse(path)
        print("the PATH of the received GET request:" + request.path)
        pathlist = request.path.split('/')
        if "/" + pathlist[1] + "/"+ pathlist[2] == prefix:
            prefix_check = True
        else:
            prefix_check = False
        className = pathlist[3]
        idName = pathlist[4]
        response = {}
        query_params = urlparse.parse_qs(request.query)
        if self.headers['Authorization'] == authheader and prefix_check is True:
            if className in SupportingFunctionList:
                datas = self.rfile.read(int(self.headers['content-length']))
                json_str = datas.decode('utf-8')
                json_str = re.sub('\'','\"', json_str)
                json_dict = json.loads(json_str)
                try:
                    print("the value of the scope : "+ str(query_params['scope']))
                    print("the value of the filter : "+ str(query_params['filter']))
                    print("the modified attribute values : "+json.dumps(json_dict['data']))
                except:
                    print("the request body doesn't follow the standard format")
                    response['error'] = "the request body doesn't follow the standard format"
                    print("Fail to modify MOI object: "+'/' +className+'/'+idName)
                    self.send_response(406)
                else:
                    find_moi = False
                    for MOI in Cretaed_MOIs_list:
                        if (idName == MOI['id'] and className == MOI['class']):
                            find_moi = True
                            wrong_attribute = False
                            for key, value in json_dict['data'].iteritems():
                                if (key in MOI['attributes']):
                                    MOI['attributes'][key] = value
                                else:
                                    wrong_attribute = True
                            if (wrong_attribute is True):
                                print("the createed MOI doesn't contain the required attribute")
                                response['error'] = "the createed MOI doesn't contain the required attribute"
                                print("Fail to get modify object: "+'/' +className+'/'+idName)
                                self.send_response(406)
                            else:
                                print("Successfully modify MOI object: "+ className+'_'+idName)
                                response = {"data":[MOI]}
                                self.send_response(200)
                    if (find_moi is False):
                        response['error'] = {"errorInfo":"MOI does not exist"}
                        print("Fail to get MOI object: "+'/' +className+'/'+idName)
                        self.send_response(406)
            else:
                response['error'] = {"errorInfo":"MOI class not support"}
                print("Fail to modify MOI object: "+'/' +className+'/'+idName)
                self.send_response(406)
        else:
            self.send_response(401)
            if prefix_check is True:
                response['error'] = {"errorInfo":"not Authorized"}
            else:
                response['error'] = {"errorInfo":"wrong prefix"}
        self.send_header("Content-type","application/json")
        self.end_headers()
        buf = json.dumps(response)
        self.wfile.write(buf)

    def do_DELETE(self):
        path = self.path
        print("\n**************************** NEW DELETE REQUEST ********************************")
        request = urlparse.urlparse(path)
        print("the PATH of the received DELETE request:" + request.path)
        pathlist = request.path.split('/')
        if "/" + pathlist[1] + "/"+ pathlist[2] == prefix:
            prefix_check = True
        else:
            prefix_check = False
        className = pathlist[3]
        idName = pathlist[4]
        response = {}
        query_params = urlparse.parse_qs(request.query)
        if self.headers['Authorization'] == authheader and prefix_check is True:
            if className in SupportingFunctionList:
                try:
                    print("the value of the scope : "+ str(query_params['scope']))
                    print("the value of the filter : "+ str(query_params['filter']))
                except:
                    print("the request body doesn't follow the standard format")
                    response['error'] = "the request body doesn't follow the standard format"
                    print("Fail to delete MOI object: "+'/' +className+'/'+idName)
                    self.send_response(406)
                else:
                    find_moi = False
                    for MOI in Cretaed_MOIs_list:
                        if (idName == MOI['id'] and className == MOI['class']):
                            find_moi = True
                            Cretaed_MOIs_list.remove(MOI)
                            print("Successfully delete MOI object: "+ className+'_'+idName)
                            response = {"data":["/"+className+"/"+idName]}
                            self.send_response(200)
                    if (find_moi is False):
                        response['error'] = {"errorInfo":"MOI does not exist"}
                        print("Fail to delete MOI object: "+'/' +className+'/'+idName)
                        self.send_response(406)
            else:
                response['error'] = {"errorInfo":"MOI class not support"}
                print("Fail to delete MOI object: "+'/' +className+'/'+idName)
                self.send_response(406)
        else:
            self.send_response(401)
            if prefix_check is True:
                response['error'] = {"errorInfo":"not Authorized"}
            else:
                response['error'] = {"errorInfo":"wrong prefix"}
        self.send_header("Content-type","application/json")
        self.end_headers()
        buf = json.dumps(response)
        self.wfile.write(buf)

    def do_PUT(self):
        path = self.path
        print("\n**************************** NEW PUT REQUEST ********************************")
        print("the PATH of the received PUT request:" + path)
        pathlist = path.split('/')
        if "/" + pathlist[1] + "/"+ pathlist[2] == prefix:
            prefix_check = True
        else:
            prefix_check = False
        className = pathlist[3]
        idName = pathlist[4]
        response = {}
        if self.headers['Authorization'] == authheader and prefix_check is True:
            if className in SupportingFunctionList:
                datas = self.rfile.read(int(self.headers['content-length']))
                json_str = datas.decode('utf-8')
                json_str = re.sub('\'','\"', json_str)
                json_dict = json.loads(json_str)
                try:
                    print("the class of the New MOI : "+json_dict['data']['class'])
                    print("the ID of the New MOI : "+json_dict['data']['id'])
                    print("the href of the New MOI : "+json_dict['data']['href'])
                    print("the attributes of the New MOI : "+json.dumps(json_dict['data']['attributes']))
                except:
                    print("the request body doesn't follow the standard format")
                    response['error'] = "the request body doesn't follow the standard format"
                    print("Fail to create MOI object: "+'/' +className+'/'+idName)
                    self.send_response(406)
                else:
                    print("Successfully create MOI object: "+ className+'/'+idName)
                    Cretaed_MOIs_list.append(json_dict['data'])
                    response = json_dict
                    self.send_response(201)
                    self.send_header("Location",path)
            else:
                response['error'] = {"errorInfo":"MOI class not support"}
                print("Fail to create MOI object: "+'/' +className+'/'+idName)
                self.send_response(406)
        else:
            self.send_response(401)
            if prefix_check is True:
                response['error'] = {"errorInfo":"not Authorized"}
            else:
                response['error'] = {"errorInfo":"wrong prefix"}
        self.send_header("Content-type","application/json")
        self.end_headers()
        buf = json.dumps(response)
        self.wfile.write(buf)

def start_server(port):
    http_server = HTTPServer((ipAddress, int(port)), ServerHTTP)
    http_server.serve_forever()

if __name__ == "__main__":
    start_server(int(portNumber))
