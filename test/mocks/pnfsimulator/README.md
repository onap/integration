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
Proper config must contain *simulatorParams*, *commonEventHeaderParams* and *pnfRegistrationParams* or notificationParams. 

###Running simulator   
The recommended way is to checkout PNF Simulator project from ONAP Git repository and use *simulator*.sh script.
If you copy *simulator.sh* script to another location, keep in mind to copy also *docker-compose.yml* and directories: *config,json_schema and netconf*.
In order to run simulator, invoke ./simulator.sh start
You may be asked for providing password for ypur user during startup.
Script downloads if necessary needed Docker images and runs instances of these images.
The easiest way is to download or generate PNF Simulator zip archive with all needed configuration files.

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
In order to disable usage of SSH keys and start using password, change in *docker-compose.yml* service *sftp-service* entry *command* from *sftp-user::1001* to *sftp-user:password:1001*

###FTPES support
PNF Simulator allows to serve files via FTPES server. FTPES server has predefined user *onap* with password *pano*. 

####FTPES support with TLS enabled
By default TLS support is enabled. In order to verify connection, please use *FileZilla* for testing.

####FTPES support for TLS disabled
For local testing TLS may be disabled, but it's not recommended. 
In order to set up such configuration, comment or remove in *ftpes-server* service section in *docker-compose.yml* following entries:
- *./ftpes/tls/:/etc/ssl/private/*
- *ADDED_FLAGS: --tls=2*

After that execute *./simulator.sh stop* and when it's finished *./simulator.sh start* .

In order to connect execute command *ftp -p localhost 2221* and, when requested, provide user and password.
In order to download a file execute, while still being logged in, *get file-name-to-be-downloaded*.

###FTPES support for VSFTPD server
PNF Simulator allows to serve files via FTPES VSFTPD server. VSFTPD server has predefined user *onap* with password *pano*.
By default TLS support is enabled. Required certificates and keys are generated via vsftpd_certs_keys_generator.sh and located in ./ftpes/vsftpd/tls/ .
We can generate our own certificates and keys using that script and passing 'secret' password when you are asked for entering keystore password. In other cases just press ENTER to go on.
Configuration of VSFTPD server is located in ./ftpes/vsftpd/configuration/vsftpd_ssl.conf .
Docker-compose contains VSFTPD server image with it's configurations.

In order to verify connection, please use *FileZilla* for testing.

###Developer mode
For development of PNF Simulator, run *simulator.sh* start-dev in order to run minimal necessary set of supporting services such as Netopeer of FTP servers.
After that it is possible to run PNF Simulator from IDE.








