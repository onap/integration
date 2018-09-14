# PNF Simulator
Simulator that generates VES events related to PNF PNP integration.

##Downloading simulator
Official version of simulator can be downloaded for public ONAP docker registry as image.
*docker login -u anonymous -p anonymous nexus3.onap.org:10003*

Another option is to checkout PNF Simulator project from ONAP Git repository.

##Usage of simulator

###Configuration
The configuration for simulator is stored in */config/config.json* file. 
It contains all parameters for simulation such as duration time,interval between messages and values of the configurable fields of VES message. 
If you want to change duration or value of message sending to VES collector you just need to edit this file. 
The message that is being sent to VES is built inside the simulator and it's content can be found in log of the simulator. 

###Running simulator   
The recommended way is to checkout PNF Simulator project from ONAP Git repository and use *simulator*.sh script
If you copy *simulator.sh* script to another location, keep in mind to copy also *docker-compose.yml* and directories: *config,json_schema and netconf*.
In order to run simulator, invoke ./simulator.sh start
Script downloads if necessary needed Docker images and runs instances of these images.

###Logging
It is possible to get access to logs by invocation of *./simulator.sh* logs. 
The content of the logs is related to the last simulator run. 
Every start of simulator will generate new logs. 

###SFTP support
PNF Simulator allows to serve files via SFTP server. SFTP server has predefined user sftp-user. 
Connection to SFTP server is being done with usage of SSH keys. Private key is stored in *ssh* directory.
In order to download *sftp-file.txt* file simply run *sftp -P 2222 -i ssh/ssh_host_rsa_key sftp-user@localhost:sftp/sftp-file.txt*
In order to add a new file (e.g. test.zip), put the file into *sftp* directory and run simulator.
After that again execute sftp command: *sftp -P 2222 -i ssh/ssh_host_rsa_key sftp-user@localhost:sftp/test.zip*

###FTPES support
PNF Simulator allows to serve files via FTPES server. FTPES server has predefined user: onap with password: pano. 
In order to connect we execute command *ftp-ssl host* and then enter user name and password.
In order to download execute command while logged in*get file_name*.
In order to add a new file execute command while logged in*put file_name*.

###Developer mode
For development of PNF Simulator, run *simulator.sh* start-dev in order to run Netopeer.
After that it is possible to run PNF Simulator from IDE.







