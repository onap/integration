# Netconf Simulator
A simulator that is able to receive and print history of CM configurations.

## Required software
To run the simulator, the following software should be installed:
- JDK 1.8
- Maven
- docker
- docker-compose

### API
Simulator exposes both HTTP and native netconf interface.

### Running simulator   
In order to run simulator, invoke *mvn clean install docker:build* to build required images.
Add executable permission to initialize_netopeer.sh (by executing `sudo chmod +x netconf/initialize_netopeer.sh`) 
and then invoke *docker-compose up* command.
In case of copying simulator files to another location, keep in mind to copy also *docker-compose.yml* and directories: *config, templates, netopeer-change-saver-native and netconf*.

#### Restarting
Restarting simulator can be done by first typing *docker-compose restart* in terminal.

#### Shutting down
The command *docker-compose down* can be used to shut the simulator down.

## Usage of simulator

### Netconf TLS support
Embedded netconf server supports connections over TLS on port 6513. Default server and CA certificate have been generated using method described below. Please proceed with these steps to recreate own certificates. Important is to fulfill all needed data during certificate preparation because Netconf verifies certs description pretty strictly. 

Mentioned Github repository contains sample client certificate, which works out of the box. 

#### Replacing server certificates
In order to replace TLS certificates with third-party ones, the following naming schema must be followed:
* CA certificate file should be named 'ca.crt'
* Netconf server certificate file should be named 'server_cert.crt'
* Netconf server keyfile file should be named 'server_key.pem'
* Client certificate file should be named 'client.crt'
* Client keyfile should be named 'client.key'

Certificates and keys should follow PEM formatting guidelines.
Prepared files should be placed under _tls/_ directory (existing files must be overwritten). 
After copying, it is necessary to restart the Netconf Simulator (please refer to [restarting simulator](restarting) guide).

This is a sample curl command to test client connection (the example assumes that Netconf Simulator runs on 127.0.0.1):
```
curl --cacert ca.crt  --cert client.crt --key client.key https://127.0.0.1:6513 -kv --http0.9
```
or using openssl:
```
openssl s_client -connect 127.0.0.1:6513 -cert client.crt -key client.key -CAfile ca.crt
```

To regenerate all required certificates follow steps:
1. Generate your private key and public certificate: ```openssl req -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt```
2. Create a private client key:```openssl genrsa -out client.key 4096```
3. Generate certificate signing request:```openssl req -new -key client.key -out client.req```
4. Generating signed client certificate: ```openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt```
5. Create a private server key:```openssl genrsa -out server_key.pem 4096```
6. Generate certificate signing request:```openssl req -new -key server_key.pem -out server.req -sha256```
7. Generating signed server certificate: ```openssl x509 -req -in server.req -CA ca.crt -CAkey ca.key -set_serial 100 -extensions server -days 1460 -outform PEM -out server_cert.crt -sha256```

Client authenticates using described TLS configuration, their username will resolve to test (more information in tls_listen.xml under the cert-to-name section). It is required that this username exists on the local system (just like for SSH), so you will need to (temporarily) create this user. The simplest way is executing # useradd -MN test, which creates the user without a home directory and user group.

Currently by default there is only a possibility to substitute existing certificates for single user. 
```


### Capturing netconf configuration changes

The netconfsimulator tool will intercept changes in netconf configuration, done by edit-config command (invoked through simulator's edit-configuration endpoint or directly through exposed netconf-compliant interface). The following changes are intercepted:
- creating new item
- moving an item
- modifying an item
- deleting an item

Each captured change contains fully qualified parameter name (including xpath - namespace and container name) 

#### REST API usage with examples

Application of native netconf operations on YANG model is covered by REST API layer. 
Example invocation of operations with its requests and results are presented below. 
For basic edit-config and get config actions, response is in plain XML format, whereas stored data that can be accessed via API is returned in JSON format.

**Load new YANG model**
http method: POST
```
URL: http:<simulator_ip>:9000/netconf/model/<moduleName>  
```
request: file content to be sent as multipart (form data)
```
module pnf-simulator {
  namespace "http://onap.org/pnf-simulator";
  prefix config;
  container config {
    config true;
    leaf itemValue1 {type uint32;}
    leaf itemValue2 {type uint32;}
    leaf itemValue3 {type uint32;}
    leaf-list allow-user {
      type string;
      ordered-by user;
      description "A sample list of user names.";
    }
  }
}
```

**Delete existing YANG model**
http method: DELETE
```
URL: http:<simulator_ip>:9000/netconf/model/<moduleName>  
```
request body should be empty.
response: a HTTP 200 code indicating successful operation or 400/500 in case of errors.

**Get all running configurations**
http method: GET
```
URL: http:<simulator_ip>:9000/netconf/get 
```
response: plain XML
```
<config xmlns="http://onap.org/pnf-simulator" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>2781</itemValue1>
  <itemValue2>3782</itemValue2>
  <itemValue3>3333</itemValue3>
</config>
<config2 xmlns="http://onap.org/pnf-simulator2" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>2781</itemValue1>
  <itemValue2>3782</itemValue2>
  <itemValue3>3333</itemValue3>
</config2>
```

**Get running configuration**
http method: GET
```
URL: http:<simulator_ip>:9000/netconf/get/'moduleName'/'container'
```
response: plain XML
```
<config xmlns="http://onap.org/pnf-simulator" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>2781</itemValue1>
  <itemValue2>3782</itemValue2>
  <itemValue3>3333</itemValue3>
</config>
```

**Edit configuration**
To edit configuration XML file must be prepared. No plain request body is used here, 
request content must be passed as multipart file (form data) with file name/key='editConfigXml' and file content in XML format

http method: POST
```
URL: http:<simulator_ip>:9000/netconf/edit-config
```
request: file content to be sent as multipart (form data)
```
<config xmlns="http://onap.org/pnf-simulator">
  <itemValue1>2781</itemValue1>
  <itemValue2>3782</itemValue2>
  <itemValue3>3333</itemValue3>
</config>
```

response: actual, running configuration after editing config:
```
<config xmlns="http://onap.org/pnf-simulator" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>2781</itemValue1>
  <itemValue2>3782</itemValue2>
  <itemValue3>3333</itemValue3>
</config>"
```

Captured change, that can be obtained from db also via REST API:

http method: GET
```
URL: http://<simulator_ip>:9000/store/less?offset=1 
```
response:
```
[{"timestamp": 1542877413979, "configuration": "CREATED: /pnf-simulator:config/itemValue3 = 3333"}]
```

Notice: if new value is the same as the old one, the change won’t be intercepted (because there is no state change). This is a limitation of used netconf implementation (Netopeer2).

**Modify request**
http method: POST
```
URL: http:<simulator_ip>:9000/netconf/edit-config
```
file content to be sent as multipart (form data):
```
<config xmlns="http://onap.org/pnf-simulator" >
  <itemValue1>111</itemValue1>
  <itemValue2>222</itemValue2>
</config>
```

response: actual, running configuration after editing config:
```
<config xmlns="http://onap.org/pnf-simulator" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>111</itemValue1>
  <itemValue2>222</itemValue2>
</config>"
```

Captured change:
http method: GET
```
URL: http://<simulator_ip>:9000/store/less?offset=2
```
```
[{"timestamp": 1542877413979, "configuration": "MODIFIED: : old value: /pnf-simulator:config/itemValue1 = 2781, new value: /pnf-simulator:config/itemValue1 = 111",
 {"timestamp": 1542877413979, "configuration": "MODIFIED: : old value: /pnf-simulator:config/itemValue2 = 3782, new value: /pnf-simulator:config/itemValue2 = 222"}]
```

**Move request** (inserting a value into leaf-list which in turn rearranges remaining elements)
http method: POST
```
URL: http:<simulator_ip>:9000/netconf/edit-config
```
file content to be sent as multipart (form data):
```
<config xmlns="http://onap.org/pnf-simulator" xmlns:yang="urn:ietf:params:xml:ns:yang:1" xmlns:xc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <allow-user xc:operation="create" yang:insert="before" yang:value="bob">mike</allow-user>
</config>
```

Captured change:
http method: GET
```
URL: http://<simulator_ip>:9000/store/less?offset=2
```
```
[{"timestamp": 1542877413979, "configuration": "CREATED: /pnf-simulator:config/allow-user = mike"},
 {"timestamp": 1542877413979, "configuration": "MOVED: /pnf-simulator:config/allow-user = mike after /pnf-simulator:config/allow-user = alice"}]
```

**Delete request**
http method: POST
```
URL: http:<simulator_ip>:9000/netconf/edit-config
```
file content to be sent as multipart (form data):
```
<config xmlns="http://onap.org/pnf-simulator">
  <itemValue1>1111</itemValue1>
  <itemValue2 xmlns:xc="urn:ietf:params:xml:ns:netconf:base:1.0" xc:operation="delete"/>
</config>
```

Captured change:
http method: GET
```
URL: http://<simulator_ip>:9000/store/less?offset=1
```
```
[{"timestamp": 1542877413979, "configuration": "DELETED: /pnf-simulator:config/itemValue2 = 222"}]
```

Getting all configuration changes:
http method: GET
```
URL: http://<simulator_ip>:9000/store/cm-history
```
response:
```
[{"timestamp":1542877413979,"configuration":"MODIFIED: : old value: /pnf-simulator:config/itemValue1 = 2781, new value: /pnf-simulator:config/itemValue1 = 111"},
 {"timestamp":1542877413979,"configuration":"MODIFIED: : old value: /pnf-simulator:config/itemValue2 = 3782, new value: /pnf-simulator:config/itemValue2 = 222"},
 {"timestamp":1542877414000,"configuration":"CREATED: : /pnf-simulator:config/itemValue3 = 3333"},
 {"timestamp":1542877414104,"configuration":"CREATED: : CREATED: /pnf-simulator:config/allow-user = mike"}
 {"timestamp":1542877414107,"configuration":"MOVED: /pnf-simulator:config/allow-user = mike after /pnf-simulator:config/allow-user = alice"},
 {"timestamp":1542877414275,"configuration":"DELETED: /pnf-simulator:config/itemValue2 = 222"}]
```

### Logging

### Swagger

## Developers Guide

### Integration tests
Integration tests use docker-compose for setting up cluster with all services. 
Those tests are not part of build pipeline, but can be run manually by invoking *mvn verify -DskipITs=false* from project command line.
Tests can be found in netconfsimulator project in src/integration directory. 

## Troubleshooting
Q: Simulator throws errors after shutting down with *docker-compose down* or *docker-compose restart*

A: Remove docker containers that were left after stopping the simulator with the following commands:
```
docker stop $(docker ps | grep netconfsimulator | awk '{print $1;}')
docker rm $(docker ps -a | grep netconfsimulator | awk '{print $1;}')
```
