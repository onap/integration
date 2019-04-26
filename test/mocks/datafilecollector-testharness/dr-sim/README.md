###Alternative to running python (as described below) on your machine, use the docker files.
1. Build docker container with ```docker build -t drsim_common:latest .```
2. Run the container ```docker-compose up```
3. For specific behavior of of the simulators, add arguments to the `command` entries in the `docker-compose.yml`.
For example `command: node dmaapDR.js --tc no_publish` . (No argument will assume '--tc normal'). Run `node dmaapDR.js --printtc`
and `node dmaapDR-redir.js --printtc` for details. 



1. install nodejs
2. install npm
Make sure that you run these commands in the application directory "dr-sim"
3. `npm install express`
4. `npm install argparse`
5. `node dmaapDR.js`   #keep it in the foreground, see item 3 in the above list for arg to the simulator
6. `node dmaapDR_redir.js`  #keep it in the foreground, see item 3 in the above list for arg to the simulator


The dmaapDR_redir server send callback to dmaapDR server to update the list of successfully published files.
As default, the ip for dmaapDR is set to work when running as container (using an ip address from the dfc_net docker network) . When running the servers from command line, set the env variable DR_SIM_IP=localhost

The simulator can be queried for statistics (use curl from cmd line or open in browser, curl used below):

DR

`curl localhost:3906/ctr_publish_query` - returns the number of publish queries

`curl localhost:3906/ctr_publish_query_published` - returns the number of responses where the files was published

`curl localhost:3906/ctr_publish_query_not_published` - returns the number of responses where the file was not published

`curl localhost:3906/ctr_publish_req` - returns the number of publish requests

`curl localhost:3906/ctr_publish_req_redirect` - returns the number of publish responses with redirect

`curl localhost:3906/ctr_publish_req_published` - returns the number of publish responses without redirect

`curl localhost:3906/ctr_published_files` - returns the number of unique published files

`curl localhost:3906/tc_info` - returns the tc name (argument on the command line)

`curl localhost:3906/execution_time` - returns the execution times in mm:ss

`curl localhost:3906/ctr_double_publish` - returns the number of double published files


DR REDIR

`curl localhost:3908/ctr_publish_requests` - returns the number of publish queries

`curl localhost:3908/ctr_publish_responses` - returns the number of publish responses

`curl localhost:3908/tc_info` - returns the tc name (argument on the command line)

`curl localhost:3908/execution_time` - returns the execution times in mm:ss

`curl localhost:3908/time_lastpublish` - returns the time (mm:ss) for the latest publish

`curl localhost:3908/dwl_volume` - returns the total received data volume of file data
