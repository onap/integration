# Introduction

The purpose of the "simulator-group" is to run all containers in one go with specified behavior.
Mainly this is needed for CSIT tests and for auto test but can be used also for manual testing of dfc both as an java-app
or as a manually started container. Instead of running the simulators manually as described below the auto-test cases
can be executed together with a java-app or a manaully started container.

In general these steps are needed to run the simulator group and dfc

1. Build the simulator images
2. Edit simulator env variables (to adapt the behavior of simulators)
3. Configure consul
4. Start the simulator monitor (to view the simulator stats)
5. Start the simulators
6. Start dfc

# Overview of the simulators.

There are 5 different types of simulators. For futher details, see the README.md in each simulator dir.

1. The MR simulator emits fileready events, upon poll requests, with new and historice file references
   It is possible to configire the change identifier and file prefixes for these identifiers and for which consumer groups
   these change identifier shall be generated. It is also possible to configure the number of events and files to generate and
   from which ftp servers the files shall be fetched from.
2. The DR simulator handles the publish queries (to check if a file has previously been published) and the
   actual publish request (which results in a redirect to the DR REDIR simulator. It keeps a 'db' of published files updated by the DR REDIR simulator.
   It is possible to configure 1 or more feeds along with the accepted filename prefixes for each feed. It is also possible
   to configure the responses for the publish queries and publish requests.
3. The DR REDIR simulator handles the redirect request for publish from the DR simulator. All accepted files will be stored as and empty
   file with a file name concatenated from the published file name + file size + feed id.
   It is possible to configure 1 or more feeds along with the accepted filename prefixes for each feed. It is also possible
   to configure the responses for the publish requests.
4. The SFTP simulator(s) handles the ftp download requests. 5 of these simulators are always started and in the MR sim it is
   possible to configure the distrubution of files over these 5 servers (from 1 up to 5 severs). At start of the server, the server is
   populated with files to download.
5. The FTPS simulator(s) is the same as the SFTP except that it using the FTPS protocol.

# Build the simulator images

Run the script `prepare-images.sh` to build the docker images for MR, DR and FTPS servers.

# Edit simulator env variables

## Summary of scripts and files

- `consul_config.sh` - Convert a json config file to work with dfc when manually started as java-app or container and then add that json to Consul.
- `dfc-internal-stats.sh` - Periodically extract jvm data and dfc internal data and print to console/file.
- `docker-compose-setup.sh` - Sets environment variables for the simulators and start the simulators with that settings.
- `docker-compose-template.yml` - A docker compose template with environment variables setting. Used for producing a docker-compose file to defined the simulator containers.
- `prepare-images.sh` - Script to build all needed simulator images.
- `setup-ftp-files-for-image.sh` - Script executed in the ftp server to create files for download.
- `sim-monitor-start.sh` - Script to install needed packages and start the simulator monitor.
- `sim-monitor.js` - The source file the simulator monitor.
- `simulators-kill.sh` - Script to kill all the simulators
- `simulators-start.sh` - Script to start all the simulators. All env variables need to be set prior to executing the script.

## Preparation

Do the manual steps to prepare the simulator images:

- Build the mr-sim image.
- cd ../mr-sim
- Run the docker build command to build the image for the MR simulator: 'docker build -t mrsim:latest .'
- cd ../dr-sim
- Run the docker build command to build the image for the DR simulators: \`docker build -t drsim_common:latest .'
- cd ../ftps-sftp-server
- Check the README.md in ftps-sftp-server dir in case the cert need to be updated.
- Run the docker build command to build the image for the DR simulators: \`docker build -t ftps_vsftpd:latest -f Dockerfile-ftps .'

## Execution

Edit the `docker-compose-setup.sh` (or create a copy) to setup the env variables to the desired test behavior for each simulators.
See each simulator to find a description of the available settings (DR_TC, DR_REDIR_TC and MR_TC).
The following env variables shall be set (example values).
Note that NUM_FTPFILES and NUM_PNFS controls the number of ftp files created in the ftp servers.
A total of NUM_FTPFILES \* NUM_PNFS ftp files will be created in each ftp server (4 files in the below example).
Large settings will be time consuming at start of the servers.
Note that the number of files must match the number of file references emitted from the MR sim.

DR_TC="--tc normal"           #Normal behavior of the DR sim

DR_REDIR_TC="--tc normal"     #Normal behavior of the DR redirect sim

MR_TC="--tc100"               #One 1 MB file in one event, once.

BC_TC=""                      #Not in use yet

NUM_FTPFILES="2"              #Two file for each PNF

NUM_PNFS="2"                  #Two PNFs

To minimize the number of ftp file creation, the following two variables can be configured in the same file.
FILE_SIZE="1MB"               #File size for FTP file (1KB, 1MB, 5MB, 50MB or ALL)
FTP_TYPE="SFTP"               #Type of FTP files to generate (SFTP, FTPS or ALL)

If `FTP_TYPE` is set to `ALL`, both ftp servers will be populated with the same files. If set to `SFTP` or `FTPS` then only the server serving that protocol will be populated with files.

Run the script `docker-compose-setup.sh`to create a docker-compose with the desired settings. The desired setting
in the script need to be manually adapted to for each specific simulator behavior according to the above. Check each simulator for available
parameters.
All simulators will be started with the generated docker-compose.yml file

To generate ftp url with IP different from localhost, set SFTP_SIM_IP and/or FTPS_SIM_IP env variables to the addreses of the ftp servers before starting. 
So farm, this only works when the simulator python script is started from the command line.

Kill all the containers with `simulators-kill.se`

`simulators_start.sh` is for CSIT test and requires the env variables for test setting to be present in the shell.

`setup-ftp-files.for-image.sh` is for CSIT and executed when the ftp servers are started from the docker-compose-setup.sh\`.

To make DFC to be able to connect to the simulator containers, DFC need to run in host mode.
Start DFC by the following cmd: `docker run -d --network="host" --name dfc_app <dfc-image> `

`<dfc-image>` could be either the locally built image `onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server`
or the one in nexus `nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server`.

# Start the simulator monitor

Start the simulator monitor server with `node sim-monitor.js` on the cmd line and the open a browser with the url `localhost:9999/mon`
to see the statisics page with data from DFC(ss), MR sim, DR sim and DR redir sim.
If needed run 'npm install express' first
