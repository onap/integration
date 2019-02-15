###Deployment of certificates: (in case of update)

This folder is prepared with a set of keys matching DfC for test purposes.

Copy from datafile-app-server/config/keys to the ./tls/ the following files:

* dfc.crt
* ftp.crt
* ftp.key

###Docker preparations
Source: https://docs.docker.com/install/linux/linux-postinstall/

`sudo usermod -aG docker $USER`

then logout-login to activate it.

###Starting/stopping the FTPS/SFTP server(s)

Start: `docker-compose up`

Stop: Ctrl +C, then `docker-compose down`  or `docker-compose down --remove-orphans`

If you experience issues (or port collision), check the currently running other containers
by using 'docker ps' and stop them if necessary.


###Cleaning docker structure
Deep cleaning: `docker system prune`