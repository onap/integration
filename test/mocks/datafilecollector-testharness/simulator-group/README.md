#Introduction
The purpose of the "simulator-group" is to run all containers in one go with specified behavior.
Mainly this is needed for CSIT tests but can be used also for local testing.


###Preparation 
Build the mr-sim image.

cd ../mr-sim

Run the docker build command to build the image for the MR simulator: 'docker build -t mrsim:latest .

cd ../dr-sim

Run the docker build command to build the image for the DR simulators: `docker build -t drsim_common:latest . 


cd ../simulator-group

Copy the 'configuration' and 'tls' catalogues from the ftps-sftp-server dir.

Check the README.md in ftps-sftp-server dir in case the cert need to be updated.

cp -r ./ftps-sftp-server/configuration .

cp -r ../ftps-sftp-server/tls .


###Execution

Edit the `docker-compose-setup.sh` to setup the env variables to the desired test behavior for each simulators.
See each simulator to find a description of the available settings.

Run the script `docker-compose-setup.sh`to create a docker-compose with the desired settings. All simulators
will be started with the generated docker-compose.yml file

Kill all the containers with `simulators-kill.se`

`simulators_start.sh` is for CSIT test and requires the env variables for test setting to be present in the shell.
`setup-ftp-files.for-image.sh` is for CSIT and executed when the ftp servers are started from the docker-compose-setup.sh`.

