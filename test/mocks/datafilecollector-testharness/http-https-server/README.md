# Generate ejbca certs for https server 

To proper run the https server certificates generated using CMPv2 server are needed. 
To do so, take the following steps:

1. Make sure if the following folders are removed `certservice/certservice-certs`, `certservice/generated`, `../simulator-group/tls`

2. `export SIM_GROUP=<path-to-the-simulator-group-folder>`

3.  In http-https-server folder run `../certservice/prepare-environment-for-cert-retrieve.sh`.

Certificates prepared for http/https server are stored in `certservice/generated/apache-certs`   

# Docker preparations

Source: <https://docs.docker.com/install/linux/linux-postinstall/>

`sudo usermod -aG docker $USER`

then logout-login to activate it.

# Prepare files for the simulator

Run `prepare.sh` with an argument found in `test_cases.yml` (or add a new tc in that file) to create files (1MB, 5MB and 50MB files) and a large number of 
symbolic links to these files to simulate PM files. The files names maches the files in
the events produced by the MR simulator. The dirs with the files will be mounted
by the ftp containers, defined in the docker-compse file, when started

# Starting/stopping the HTTP/HTTPS server(s)

Start: `docker-compose up`

Stop: Ctrl +C, then `docker-compose down`  or `docker-compose down --remove-orphans`

If you experience issues (or port collision), check the currently running other containers
by using 'docker ps' and stop them if necessary.

# Cleaning docker structure

Deep cleaning: `docker system prune`
