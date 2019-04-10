#Introduction
The purpose of the "simulator-group" is to run all containers in one go with specified behavior.
Mainly this is needed for CSIT tests but can be used also for local testing.


###Preparation 
Do the manual steps to prepare the simulator images

Build the mr-sim image.

cd ../mr-sim

Run the docker build command to build the image for the MR simulator: 'docker build -t mrsim:latest .'

cd ../dr-sim

Run the docker build command to build the image for the DR simulators: `docker build -t drsim_common:latest .'


cd ../simulator-group

Copy the 'configuration' and 'tls' catalogues from the ftps-sftp-server dir.

Check the README.md in ftps-sftp-server dir in case the cert need to be updated.

cp -r ../ftps-sftp-server/configuration .

cp -r ../ftps-sftp-server/tls .


###Execution

Edit the `docker-compose-setup.sh` (or create a copy) to setup the env variables to the desired test behavior for each simulators.
See each simulator to find a description of the available settings.
The following env variables shall be set (example values).
Note that NUM_FTPFILES and NUM_PNFS controls the number of ftp files created in the ftp servers. 
A total of NUM_FTPFILES * NUM_PNFS ftp files will be created in each dtp server (4 files in the below example). 
Large settings will be time consuming at start of the servers.

DR_TC="--tc normal"           #Normal behavior of the DR sim

DR_REDIR_TC="--tc normal"     #Normal behavior of the DR redirect sim

MR_TC="--tc100"               #One 1 MB file in one event, once. 

BC_TC=""                      #Not in use yet

NUM_FTPFILES="2"              #Two file for each PNF

NUM_PNFS="2"                  #Two PNFs

Run the script `docker-compose-setup.sh`to create a docker-compose with the desired settings. The desired setting
in the script need to be manually adapted to for each specific simulator behavior according to the above. Check each simulator for available
parameters.
All simulators will be started with the generated docker-compose.yml file

To generate ftp url with IP different from localhost, set SFTP_SIM_IP and/or FTPS_SIM_IP env variables to the addreses of the ftp servers before starting. 
So farm, this only works when the simulator python script is started from the command line.

Kill all the containers with `simulators-kill.se`

`simulators_start.sh` is for CSIT test and requires the env variables for test setting to be present in the shell.
`setup-ftp-files.for-image.sh` is for CSIT and executed when the ftp servers are started from the docker-compose-setup.sh`.

To make DFC to be able to connect to the simulator containers, DFC need to run in host mode.
Start DFC by the following cmd: `docker run -d --network="host" --name dfc_app <dfc-image> `

`<dfc-image>` could be either the locally built image `onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server`
or the one in nexus `nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server`. 



###Simulator monitor
Start the simulator monitor server with `sim-monitor-start.sh` and the open a browser with the url `localhost:9999/mon`
to see the statisics page with data from MR sim, DR sim and DR redir sim.
