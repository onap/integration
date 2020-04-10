# Deployment of certificates: (in case of update)

This folder is prepared with a set of keys matching DfC for test purposes.

Copy from datafile-app-server/config/keys to the ./tls/ the following files:

- dfc.crt
- ftp.crt
- ftp.key

# Docker preparations

Source: <https://docs.docker.com/install/linux/linux-postinstall/>

`sudo usermod -aG docker $USER`

then logout-login to activate it.

# Prepare files for the simulator

Run `prepare.sh` with an argument found in `test_cases.yml` (or add a new tc in that file) to create files (1MB, 5MB and 50MB files) and a large number of 
symbolic links to these files to simulate PM files. The files names maches the files in
the events produced by the MR simulator. The dirs with the files will be mounted
by the ftp containers, defined in the docker-compse file, when started

# Starting/stopping the FTPS/SFTP server(s)

Start: `docker-compose up`

Stop: Ctrl +C, then `docker-compose down`  or `docker-compose down --remove-orphans`

If you experience issues (or port collision), check the currently running other containers
by using 'docker ps' and stop them if necessary.

# Cleaning docker structure

Deep cleaning: `docker system prune`
