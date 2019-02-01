# Postman Collections

## Using Postman

That repository contains 9 Postman collections and 2 environment files.

They have been tested with Onap Casablanca (they are not compatible with
  Beijing, and there is not guaranty about ONAP "master" as API definition
  can change)

You first need to import all those files into your Postman.
![postman](./images/import.png)

And you should see all the collections
![postman](./images/collections.png)

Each collection is made of several API operations
![postman](./images/collection-detail.png)

Running all those collections, in the order, from 1 to 8 will create a lot of
objects in ONAP components :

- SDC : vendor, VSP, zip file upload, VF from VSP, Service, add VF to Service
- VID : OwningEntity, LineOfBusiness, Project, Platform
- AAI : customer, subscription, cloud region, tenant
- NBI : serviceOrder to add a service instance, serviceOrder to delete a service
 instance

The order is very important because a lot of API request will need the API
 response from the previous operation.
![postman](./images/collection-detail-test.png)

It is possible to run the complete collection using Postman
![postman](./images/run.png)

You need, a zip file that contains Heat files for a VNF.

Collection 3 is about uploading that file into ONAP SDC.
![postman](./images/zipfile.png)

Before running those collections, once in Postman, you need to have a look
at "globals" environment parameters.
![postman](./images/globals.png)

All variables that begin by "auto_" must not be change (they will be modified
 using API response)
All other variables must be adapted to your needs.
In particular, you need to put your own values for cloud_region_id, tenant_name
 and tenant_id to fit with the place where you will instantiate the VNF

```yaml
 service:freeradius
 vf_name:integration_test_VF_freeradius
 vsp_name:integration_test_VSP
 vendor_name:onap_integration_vendor
 owning_entity:integration_test_OE
 platform:integration_test_platform
 project:integration_test_project
 lineofbusiness:integration_test_LOB
 customer_name:generic
 cloud_owner_name:OPNFV
 cloud_region_id:RegionOne
 tenant_name:openlab-vnfs
 tenant_id:234a9a2dc4b643be9812915b214cdbbb
 externalId:integration_test_BSS-001
 service_instance_name:integration_test_freeradius_instance_001
 listener_url:http://10.4.2.65:8080/externalapi/listener/v1/listener
```

## Using Newman

Newman is a tool that allow to run postman collections via CLI

Using a Linux server, just run those lines:

```shell
git clone https://gitlab.com/Orange-OpenSource/lfn/onap/onap-tests.git
cd onap-tests/postman
sudo apt-get -y install zip
USECASE=$'ubuntu16'
zip -j $USECASE.zip ../onap_tests/templates/heat_files/$USECASE/*
TAB=$'\t\t\t\t\t\t\t'
sed -i -e "s/.*src.*/$TAB\"src\": \"$USECASE.zip\"/" 03_Onboard_VSP_part2.postman_collection.json
docker pull postman/newman:alpine
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 01_Onboard_Vendor.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json --reporters cli,json --reporter-cli-no-assertions --reporter-cli-no-console
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 02_Onboard_VSP_part1.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 03_Onboard_VSP_part2.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 04_Onboard_VSP_part3.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 05_Onboard_VF.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 06_Onboard_Service.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 07_Declare_owningEntity_LineOfBusiness_project_platform.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 08_Declare_Customer_Service_Subscription_Cloud.postman_collection.json --insecure --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json
docker run --network="host" --volume="/home/debian/rene/onap-tests/postman:/etc/newman" postman/newman:alpine run 10_Service_Order.postman_collection.json --environment integration_test_urls.postman_environment.json --globals globals.postman_globals.json --export-globals globals.postman_globals.json --reporters cli,json --reporter-cli-no-assertions --reporter-cli-no-console
```

All collections are run, you can see results and you will also obtain result json files in the onap-tests/postamn/newman directory

Of course you can adapt globals variables in globals.postman_globals.json or change the USECASE=$'ubuntu16' value to onboard any heat template located in onap_tests/templates/heat_files directory
