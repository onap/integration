Python Dependence: python 2.7.x

 
1. To specify the supported NRM function in DefinedNRMFunction.json

 
2. To specify the HTTP server configuration info in ConfigInfo.json

 
3. To specify the User info in UserInfo.json

 
4. To specify the pre-set-MOI info in preSetMOI.json

 
5. To run the HTTP EMS simulator: python ProvMnSProvider.py

Build the image by using the command: docker build . -t prov-mns-provider
Create the container and start the service by using the command: docker-compose up -d

The default port number of ProvMnSProvider is : 8000

The default username&password of ProvMnSProvider is : root&root

ProvMnSProvider provdies four RESTful APIs:

1. Sample PUT request to Create MOI 
   PUT /ProvisioningMnS/v1500/GNBCUCPFunction/35c369d0-2681-4225-9755-daf98fd20805
   {
    "data": {
        "attributes": {
            "pLMNId": {
                "mnc": "01",
                "mcc": "001"
            },
            "gNBId": "1",
            "gNBIdLength": "5",
            "gNBCUName": "gnb-01"
        },
        "href": "/GNBCUCPFunction/35c369d0-2681-4225-9755-daf98fd20805",
        "class": "GNBCUCPFunction",
        "id": "35c369d0-2681-4225-9755-daf98fd20805"
    }
   }

2. Sample GET request to get MOI attributes
   GET /ProvisioningMnS/v1500/GNBCUCPFunction/35c369d0-2681-4225-9755-daf98fd20805?scope=BASE_ONLY&filter=GNBCUCPFunction&fields=gNBId&fields=gNBIdLength

3. Sample PATCH request to modify MOI attributes
   PATCH /ProvisioningMnS/v1500/GNBCUCPFunction/35c369d0-2681-4225-9755-daf98fd20805?scope=BASE_ONLY&filter=GNBCUCPFunction
   {
    "data": {
         "pLMNId": "xxx",
         "gNBId": "1234",
         "gNBIdLength": "4"
    }
   }

4. Sample DELETE request to delete MOI
   DELETE /ProvisioningMnS/v1500/GNBCUCPFunction/35c369d0-2681-4225-9755-daf98fd20805?scope=BASE_ONLY&filter=GNBCUCPFunction
   