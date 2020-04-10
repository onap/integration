# Run DR simulators as docker container

1. Build docker container with `docker build -t drsim_common:latest .`
2. Run the container `docker-compose up`
3. For specific behavior of of the simulators, add arguments to the `command` entries in the `docker-compose.yml`.

For example `command: node dmaapDR.js --tc no_publish` . (No argument will assume '--tc normal'). Run `node dmaapDR.js --printtc`
and `node dmaapDR-redir.js --printtc` for details or see further below for the list of possible arg to the simulator

# Run DR simulators and all other simulators as one group

See the README in the 'simulator-group' dir.

# Run DR simulators from cmd line

1. install nodejs
2. install npm

Make sure that you run these commands in the application directory "dr-sim"

3. `npm install express`
4. `npm install argparse`
5. `node dmaapDR.js`   #keep it in the foreground, see below for a list for arg to the simulator
6. `node dmaapDR_redir.js`  #keep it in the foreground, see below for a list for arg to the simulator

# Arg to control the behavior of the simulators

## DR

\--tc tc_normal                      Normal case, query response based on published files. Publish respond with ok/redirect depending on if file is published or not.</br>

\--tc tc_none_published              Query respond 'ok'. Publish respond with redirect.</br>

\--tc tc_all_published               Query respond with filename. Publish respond with 'ok'.</br>

\--tc tc_10p_no_response             10% % no response for query and publish. Otherwise normal case.</br>

\--tc tc_10first_no_response         10 first queries and requests gives no response for query and publish. Otherwise normal case.</br>

\--tc tc_100first_no_response        100 first queries and requests gives no response for query and publish. Otherwise normal case.</br>

\--tc tc_all_delay_1s                All responses delayed 1s (both query and publish).</br>

\--tc tc_all_delay_10s               All responses delayed 10s (both query and publish).</br>

\--tc tc_10p_delay_10s               10% of responses delayed 10s, (both query and publish).</br>

\--tc tc_10p_error_response          10% error response for query and publish. Otherwise normal case.</br>

\--tc tc_10first_error_response      10 first queries and requests gives no response for query and publish. Otherwise normal case.</br>

\--tc tc_100first_error_response     100 first queries and requests gives no response for query and publish. Otherwise normal case.</br>

## DR Redirect

\--tc_normal                         Normal case, all files publish and DR updated.</br>

\--tc_no_publish                     Ok response but no files published.</br>

\--tc_10p_no_response                10% % no response (file not published).</br>

\--tc_10first_no_response            10 first requests give no response (files not published).</br>

\--tc_100first_no_response           100 first requests give no response (files not published).</br>

\--tc_all_delay_1s                   All responses delayed 1s, normal publish.</br>

\--tc_all_delay_10s                  All responses delayed 10s, normal publish.</br>

\--tc_10p_delay_10s                  10% of responses delayed 10s, normal publish.</br>

\--tc_10p_error_response             10% error response (file not published).</br>

\--tc_10first_error_response         10 first requests give error response (file not published).</br>

\--tc_100first_error_response        100 first requests give error responses (file not published).</br>

# Needed environment

## DR

```
DRR_SIM_IP     Set to host name of the DR Redirect simulator "drsim_redir" if running the simulators in a docker private network. Otherwise to "localhost"
DR_FEEDS       A comma separated list of configured feednames and filetypes. Example "1:A,2:B:C" - Feed 1 for filenames beginning with A and feed2 for filenames beginning with B or C.
```

`DRR_SIM_IP` is needed for the redirected publish request to be redirected to the DR redirect server.

## DR Redirect (DRR for short)

```
DR_SIM_IP      Set to host name of the DR simulator "drsim" if running the simulators in a docker private network. Otherwise to "localhost"
DR_REDIR_FEEDS Same contentd as DR_FEEDS for DR.
```

The DR Redirect server send callback to DR server to update the list of successfully published files.
When running as container (using an ip address from the `dfc_net` docker network) the env shall be set to 'drsim'. . When running the servers from command line, set the env variable `DR_SIM_IP=localhost`

# APIs for statistic readout

The simulator can be queried for statistics (use curl from cmd line or open in browser, curl used below):

## DR

`curl localhost:3906/` - returns 'ok'

`curl localhost:3906/tc_info` - returns the tc id

`curl localhost:3906/execution_time` - returns the execution time in the format mm_ss

`curl localhost:3906/feeds` - returns the list of configured feeds

`curl localhost:3906/ctr_publish_query` - returns the number of publish queries for all feeds

`curl localhost:3906/feeds/ctr_publish_query` -returns a list of number of publish queries in each feed

`curl localhost:3906/ctr_publish_query/<feed>` - returns the number of publish queries for a feed

`curl localhost:3906/ctr_publish_query_published` - returns the number of query responses for all feeds where the files were published

`curl localhost:3906/feeds/ctr_publish_query_published` - returns a list of the number of query responses for each feed where the files were published

`curl localhost:3906/ctr_publish_query_published/<feed>` - returns the number of query responses for a feed where the files were published

`curl localhost:3906/ctr_publish_query_not_published` - returns the number of query responses for all feed where the files were not published

`curl localhost:3906/feeds/ctr_publish_query_not_published` - returns a list of the number of query responses for each feed where the files were not published

`curl localhost:3906/ctr_publish_query_not_published/<feed>` - returns the number of query responses for a feed where the files were not published

`curl localhost:3906/ctr_publish_req` - returns the number of publish requests for all feeds

`curl localhost:3906/feeds/ctr_publish_req` - returns a list of the number of publish requests for each feed

`curl localhost:3906/ctr_publish_req/<feed>` - returns the number of publish requests for feed

`curl localhost:3906/ctr_publish_req_redirect` - returns the number of publish responses with redirect for all feeds

`curl localhost:3906/feeds/ctr_publish_req_redirect` - returns a list of the number of publish responses with redirect for each feed

`curl localhost:3906/ctr_publish_req_redirect/<feed>` - returns the number of publish responses with redirect for a feed

`curl localhost:3906/ctr_publish_req_published` - returns the number of publish responses where files have been published (no redirect) for all feeds

`curl localhost:3906/feeds/ctr_publish_req_published` - returns a list of the number of publish responses where files have been published (no redirect) for each feeds

`curl localhost:3906/ctr_publish_req_published/<feed>` - returns the number of publish responses where files have been published (no redirect) for a feed

`curl localhost:3906/ctr_published_files` - returns the number of published files for all feeds

`curl localhost:3906/feeds/ctr_published_files` -  returns  a list of the number of published files for each feed

`curl localhost:3906/ctr_published_files/<feed>` - returns the number of published files for a feed

`curl localhost:3906/ctr_double_publish` - returns the number of double published files for all feeds

`curl localhost:3906/feeds/ctr_double_publish` -  returns  a list of the number of double published files for each feed

`curl localhost:3906/ctr_double_publish/<feed>` -  returns  a list of the number of double published files for a feed

`curl localhost:3906/ctr_publish_query_bad_file_prefix` - returns the number of publish queries with bad file prefix for all feeds

`curl localhost:3906/feeds/ctr_publish_query_bad_file_prefix` -  returns  a list of the number of publish queries with bad file prefix for each feed

`curl localhost:3906/ctr_publish_query_bad_file_prefix/<feed>` -  returns  a list of the number of publish queries with bad file prefix for a feed

## DR Redirect

`curl localhost:3908/` - returns 'ok'

`curl localhost:3908/tc_info` - returns the tc id

`curl localhost:3908/execution_time` - returns the execution time in the format mm:ss

`curl localhost:3908/feeds` - returns the list of configured feeds

`curl localhost:3908/speed` - returns the speed in published files per second

`curl localhost:3908/ctr_publish_requests` - returns the number of publish requests for all feeds

`curl localhost:3908/feeds/ctr_publish_requests` - returns a list of the number of publish requests for each feed

`curl localhost:3908/ctr_publish_requests/<feed>` - returns the number of publish requests for a feed

`curl localhost:3908/ctr_publish_requests_bad_file_prefix` - returns the number of publish requests with bad file prefix for all feeds

`curl localhost:3908/feeds/ctr_publish_requests_bad_file_prefix` - returns a list of the number of publish requests with bad file prefix for each feed

`curl localhost:3908/ctr_publish_requests_bad_file_prefix/<feed>` - returns the number of publish requests with bad file prefix for a feed

`curl localhost:3908/ctr_publish_responses` - returns the number of publish responses for all feeds

`curl localhost:3908/feeds/ctr_publish_responses` - returns a list of the number of publish responses for each feed

`curl localhost:3908/ctr_publish_responses/<feed>` - returns the number of publish responses for a feed

`curl localhost:3908/time_lastpublish` - returns the time of the last successful publish in the format mm:ss for any feed

`curl localhost:3908/feeds/time_lastpublish` - returns a list of the time of the last successful publish in the format mm:ss for each feed

`curl localhost:3908/time_lastpublish/<feed>` - returns the time of the last successful publish in the format mm:ss for a feed

`curl localhost:3908/dwl_volume` - returns the number of bytes of published files for all feeds

`curl localhost:3908/feeds/dwl_volume` - returns a list of the number of bytes of the published files for each feed

`curl localhost:3908/dwl_volume/<feed>` - returns the number of bytes of the published files for a feed
