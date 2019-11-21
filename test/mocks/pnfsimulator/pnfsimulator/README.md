# PNF Simulator
Simulator that generates VES events related to PNF PNP integration.

## Usage of simulator
### Setting up
Preferred way to start simulator is to use `docker-compose up -d` command.
All required docker images will be downloaded from ONAP Nexus, however there is possibility to build those 
images locally. It can be achieve by invoking `mvn clean package docker:build` from top directory.
 
### API
Simulator provides REST endpoints which can be used to trigger sending events to VES.

*Periodic event sending*
To trigger sending use following endpoint *http://<simulator_ip>:5000/simulator/start*.  
Supported method: *POST*  
Headers:  
    - Content-Type - application/json  
Parameters: 
    
    simulatorParams:
        repeatCount    -  determines how many events will be sent
        repeatInterval -  time (in seconds) between events
        vesServerUrl   -  valid path to VES Collector
    templateName   -  name of template file (check *Templates* section) 
    patch          -  part of event which will be merged into template

  
Sample Request:

    {
      "simulatorParams": {
        "repeatCount": 5,
        "repeatInterval": 2,
        "vesServerUrl": "http://VES-HOST:8080/eventListener/v7"
      },
      "templateName": "validExampleMeasurementEvent.json",
      "patch": {
                   "event": {
                       "commonEventHeader": {
                           "eventId": "PATCHED_eventId",
                           "sourceName": "PATCHED_sourceName",
                           "version": 3.0
                       }
                   }
               }
    }
    
*One-time event sending*
Enables direct, immediate event sending without need to have template deployed on backend.
Keywords are supported,thus once passed, will also be substituted with proper strings. 
Passed event body must be valid and complete event according to VES Collector interface. 
To trigger sending use following endpoint *http://<simulator_ip>:5000/simulator/event*. 

Supported method: *POST*  
Headers:  
    - Content-Type - application/json  
Parameters: 
    
    vesServerUrl   -  valid URL to VES Collector event listener
    event          -  body of event to be sent directly to VES Collector (it can contain keyword expressions)

  
Sample Request:

    {
      "vesServerUrl": "http://VES-HOST:8080/eventListener/v7",
      "event": {
        "commonEventHeader": {
          "eventId": "#RandomString(20)",
          "sourceName": "PATCHED_sourceName",
          "version": 3.0
        }
      }
    }
    
### Changing simulator configuration
Utility of default configuration has been introduced so as to facilitate sending requests. so far only vesServerUrl states default simulator configuration.
On simulator startup, vesServerUrl is initialized with default value, but must be replaced with correct VES server url by user.
Once vesServerUrl is properly set on simulator, this parameter does not need to be incorporated into every trigger event request.
If user does not provide vesServerUrl in trigger request, default value will be used.
If use does provide vesServerUrl in trigger request, then passed value will be used instead of default one (default value will not be overwritten by provided one).

It is possible to get and update configuration (current target vesServerUrl) using offered REST API - */simulator/config* endpoint is exposed for that.
To get current configuration *GET* method must be used.
To update vesServerUrl *PUT* method is used, example request: 

    {
      "vesServerUrl": "http://10.154.164.117:8080/eventListener/v7"
    }
  
Note: passed vesServerUrl must be wellformed URL.


### Running simulator   
The recommended way is to checkout PNF Simulator project from ONAP Git repository and use *simulator*.sh script.
If you copy *simulator.sh* script to another location, keep in mind to copy also *docker-compose.yml* and directories: *config and templates*.
In order to run simulator, invoke ./simulator.sh -e build to build required images and then invoke ./simulator.sh -e start
Script downloads if necessary needed Docker images and runs instances of these images. 
After simulator start it is advisable to setup default value for target vesServerUrl. 

Example request:

    PUT to http://<simulator_ip>:<simulator_port>/simulator/config

    {
       "vesServerUrl": "PUT HERE VALID URL TO YOUR VES EVENT LISTENER"
    }

### Templates
Template is a draft event. Merging event with patch will result in valid VES event. Template itself should be a correct VES event as well as valid json object. 
In order to apply custom template, just copy it to ./templates directory.
*notification.json* and *registration.json* are available by default in *./templates* directory.

#### Template management
The simulator provides means for managing templates. Supported actions: adding, editing (overriding) and deleting are available via HTTP endpoint */template*

```GET /template/list```  
Lists all templates known to the simulator.

```GET /template/get-content/{name}```  
Gets template content based on *name* path variable.

```POST /template/upload?override=true```  
Saves template content under *name* path variable. The non-mandatory parameter *override* allows overwriting an existing template.

Sample payload:
```
{
  "name": "someTemplate",
  "template": {
    "commonEventHeader": {
      "domain": "notification",
      "eventName": "vFirewallBroadcastPackets"
    },
    "notificationFields": {
      "arrayOfNamedHashMap": [{
        "name": "A20161221.1031-1041.bin.gz",
        "hashMap": {
          "fileformatType": "org.3GPP.32.435#measCollec"
        }
      }]
    }
  }
}
```

### Searching for key-value conditions in stored templates
Simulator allows to search through stored templates and retrieve names of those that satisfy given criteria passed in form of key-value pairs (See examples below).
Following data types are supported in search as values:
-integer
-string
-double
-boolean
Searching for null values as well as incorporating regex expression with intention to find a match is not supported.
Search expression must be valid JSON, thus no duplicate keys are allowed - user could specify the same parameter multiple times, but only last occurrence will be applied to query.
Example search expression:

{"domain": "notification", "sequence": 1, "startEpochMicrosec": 1531616794, "sampleDouble": 2.5}

will find all templates that contain all of passed key-value entries. There is an AND condition beetwen given criteria - all of them must be satisfied to qualify template as matching item.
 Keys of search expressions are searched in case insensitive way as well as string values.
Where it comes to values of numerical and boolean type exact match is expected.

API usage:

```POST /template/search```
Produces query that returns templates that contain searched criteria

Sample payload:
```
{
  "searchExpr": {
    "domain": "notification",
    "sequence": 1,
    "startEpochMicrosec": 1531616794,
    "sampleDouble": 2.5
    }
}
```
Sample response:
```
[notification.json]
```
 

Note: Manually deployed templates, or actually existing ones, but modified inside the templates catalog '/app/templates', will be automatically synchronized with schemas stored inside the database.  That means that a user can dynamically change the template content using vi editor at simulator container, as well as use any editor at any machine and then push the changes to the template folder. All the changes will be processed 'on the fly' and accessible via the rest API.

### Periodic events
Simulator has ability to send event periodically. Rest API support parameters:
* repeatCount - count of times that event will be sent to VES
* repeatInterval - interval (in second) between two events.
(Checkout example to see how to use them)

### Patching
User is able to provide patch in request, which will be merged into template.  

Warning: Patch should be a valid json object (no json primitives nor json arrays are allowed as a full body of patch).

This mechanism allows to override part of template. 
If in "patch" section there are additional parameters (absent in template), those parameters with values will be added to event.
Patching mechanism supports also keywords that enables automatic value generation of appropriate type

### Keyword support
Simulator supports corresponding keywords:
- \#RandomInteger(start,end) - substitutes keyword with random positive integer within given range (range borders inclusive)
- \#RandomPrimitiveInteger(start,end) - the same as #RandomInteger(start,end), but returns long as result
- \#RandomInteger -  substitutes keyword with random positive integer
- \#RandomString(length) - substitutes keyword with random ASCII string with specified length
- \#RandomString - substitutes keyword with random ASCII string with length of 20 characters
- \#Timestamp - substitutes keyword with current timestamp in epoch (calculated just before sending event)
- \#TimestampPrimitive - the same as \#Timestamp, but returns long as result
- \#Increment - substitutes keyword with positive integer starting from 1 - for each consecutive event, value of increment property is incremented by 1

Additional hints and restrictions:
All keywords without 'Primitive' in name return string as result. To specify keyword with 2 arguments e.g. #RandomInteger(start,end) no whitespaces between arguments are allowed.
Maximal value of arguments for RandomInteger is limited to the java integer range. Minimal is always 0. (Negative values are prohibited and wont be treated as a correct parts of keyword).
RandomInteger with parameters will automatically find minimal and maximal value form the given attributes so no particular order of those is expected.    

How does it work?
When user do not want to fill in parameter values that are not relevant from user perspective but are mandatory by end system, then keyword feature should be used.
In template, keyword strings are substituted in runtime with appropriate values autogenerated by simulator. 
Example can be shown below:

Example template with keywords:
  
    {
      "event": {
        "commonEventHeader": {
          "eventId": "123#RandomInteger(8,8)",
          "eventType": "pnfRegistration",
          "startEpochMicrosec": "#Timestamp",
          "vesEventListenerVersion": "7.0.1",
          "lastEpochMicrosec": 1539239592379
        },
        "pnfRegistrationFields": {
          "pnfRegistrationFieldsVersion":"2.0",
          "serialNumber": "#RandomString(7)",
          "vendorName": "Nokia",
          "oamV4IpAddress": "val3",
          "oamV6IpAddress": "val4"
        }
      }
    }

Corresponding result of keyword substitution (event that will be sent):
  
    {
      "event": {
        "commonEventHeader": {
          "eventId": "1238",
          "eventType": "pnfRegistration",
          "startEpochMicrosec": "154046405117",
          "vesEventListenerVersion": "7.0.1",
          "lastEpochMicrosec": 1539239592379
        },
        "pnfRegistrationFields": {
          "pnfRegistrationFieldsVersion":"2.0",
          "serialNumber": "6061ZW3",
          "vendorName": "Nokia",
          "oamV4IpAddress": "val3",
          "oamV6IpAddress": "val4"
        }
      }
    }
 

### Logging
Every start of simulator will generate new logs that can be found in docker pnf-simualtor container under path: 
/var/log/ONAP/pnfsimulator/pnfsimulator_output.log

### Swagger
Detailed view of simulator REST API is available via Swagger UI
Swagger UI is available on *http://<simulator_ip>:5000/swagger-ui.html*

### History
User is able to view events history.  
In order to browse history, go to *http://<simulator_ip>:8081/db/pnf_simulator/eventData*

### TLS Support
Simulator is able to communicate with VES using HTTPS protocol.
CA certificates are incorporated into simulator docker image, thus no additional actions are required from user.

Certificates can be found in docker container under path: */usr/local/share/ca-certificates/*

Simulator works with VES that uses both self-signed certificate (already present in keystore) and VES integrated to AAF. 
 

## Developers Guide

### Integration tests
Integration tests are located in folder 'integration'. Tests are using docker-compose from root folder. 
This docker-compose has pnfsimulator image set on nexus3.onap.org:10003/onap/pnf-simulator:5.0.0-SNAPSHOT. 
To test your local changes before running integration tests please build project using:

    'mvn clean package docker:build'
    
then go to 'integration' folder and run: 

    'mvn test'
    
### Client certificate authentication
Simulator can cooperate with VES server in different security types in particular ```auth.method=certBasicAuth``` which means that it needs to authenticate using client private certificate. 

Warning: according to VES implementation which uses certificate with Common Name set to DCAELOCAL we decided not to use strict hostname verification, so at least this parameter is skipped during checking of the client certificate.

#### How to generate client correct keystore for pnf-simulator
 The Root CA cert is available in certs folder in VES repository. The password for rootCA.key is collector.
 
 The procedure of generating client's certificate:
 1. Generate a private key for the SSL client: ```openssl genrsa -out client.key 2048```
 2. Use the client’s private key to generate a cert request: ```openssl req -new -key client.key -out client.csr```
 3. Issue the client certificate using the cert request and the CA cert/key: ```openssl x509 -req -in client.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out client.crt -days 500 -sha256```
 4. Convert the client certificate and private key to pkcs#12 format: openssl pkcs12 -export -inkey client.key -in client.cer -out client.p12
 5. Copy pkcs file into pnf simulators folder: ```/app/store/```
 
#### How to generate correct truststore for pnf-simulator
 Create truststore with rootCA.crt: 
 1. ```keytool -import -file rootCA.crt -alias firstCA -keystore trustStore```
 2. Copy truststore to ```/app/store/```

#### How to refresh configuration of app
Depends your needs, you are able to change client certificate, replace trustStore to accept new server certificate change keystore and truststore passwords or completely disable client cert authentication.

For this purpose:
1. Go to the pnf simulator container into the /app folder.
2. If you want to replace keystore or truststore put them into the /app/store folder.
3. Edit /app/application.properties file as follow:
- ssl.clientCertificateEnabled=true (to disable/enable client authentication)
- ssl.clientCertificateDir=/app/store/client.p12 (to replace keystore file)
- ssl.clientCertificatePassword=collector (to replace password for keystore)
- ssl.trustStoreDir=/app/store/trustStore (to replace truststore file)
- ssl.trustStorePassword=collector (to replace password for truststore)
4. Refresh configuration sending simple POST request to correct actuator endpoint at: ```curl http://localhost:5001/refresh -H 'Content-type: application/json' -X POST --data '{}'```
