# Xtesting-onap-robot
Reuse of the Xtesting framework to onboard ONAP robot tests
It consists in 3 files:
  * Dockerfile: create your dockerfile. For Beijing, it shall be generated manually. You can use a non official version [4]
  * testcases.yaml: the list of the testcases based on robotframework tags as defined in ONAp repo [3]
  * thirdparty-requirements.txt: dependencies needed by the Dockerfile

## Configuration

To launch Xtesting ONAP robot you need 2 files
  * env
  * onap.properties: list of ONAP endpoints (can be found on the robot VM). Depending from where you launch the tests,
please check that the IP addresses are reachable.

As Xtesting supports both Openstack and Kubernetes, the env files shall be set accordingly.

env file
```
INSTALLER_TYPE=heat
DEPLOY_SCENARIO=os-nosdn-nofeature-ha
EXTERNAL_NETWORK=ext-network
NODE_NAME=pod4-orange-heat1
TEST_DB_URL=hhttp://testresults.opnfv.org/onap/api/v1/results
BUILD_TAG=jenkins-functest-kolla-baremetal-daily-amsterdam-222
```

All the values of the env file are not mandatory.

### INSTALLER_TYPE
It indicates how you deploy your ONAP solution. The possible values are heat or oom.

### DEPLOY_SCENARIO
If you do not precise DEPLOY_SCENARIO, it will be set to os-nosdn-nofeature-nohai by default, which means
Openstack / No Additional SDN controller / No Additional feature / no HA mode
This parameter can be useful if you manage several infrastructure and want to filter the results.
Other possible scenario:
  * k8-nosdn-nofeature-ha (Kubernetes with no add-ons)
  * os-odl-nofeature-ha (Openstack with Opendaylight SDN controller)

### EXTERNAL_NETWORK (Openstack only)
You must precise it if it is not the first network with router:external=True

### KUBERNETES_PROVIDER (Kubernetes only)
This parameter is set to local by default

### KUBE_MASTER_URL (Kubernetes only)
You must indicate your Kubernetes Master URL.

### KUBE_MASTER_IP (Kubernetes only)
You must indicate your Kubernetes Master IP.

### NODE_NAME
The NODE_NAME is the name of the infrastructure that you declared in the Test DB. If you do not want to report the
results to the Test Database, you do not need to precise this parameter.

### TEST_DB_URL
This parameter corresponds to the Test Database FQDN.
If you do not want to report the results to the Test Database, you do not need to precise this parameter.

You can reference either your own local database or a public Database (You must be sure that your NODE_NAME has been declared on
this database). If so, and if you precise the flag to report the results, the test results will be automatically pushed.

### BUILD_TAG
This parameter is used to retrieve the version (amsterdam in the example) for the publication in the test database.
If you do not publish the results, you can omit it.
It is based on an historical regex setup for OPNFV CI/CD chains. 

All the parameters are detailed in Functest user guide [1].

## onap.properties

This file includes all the ONAP end points. It is built at ONAP installation and can be found on the ONAP Robot VM.

# Launch xtesting-onap-robot

You can run the test with the following command:

sudo docker run --env-file <your env> -v <your onap properties>:/share/config/integration_vm_properties.py colvert22/functest-onap:latest

By default it will execute all the tests corresponding to the command bash -c 'run_tests -t all'

If you want to execute only a subset of the tests you may precise the test cases using -t: bash -c 'run_tests -t robot_dcae'

The possible test cases are indicated in the testcases.yaml and are based on robotframework tags.

If you want to push the results to the database, you can use the -r option:  bash -c 'run_tests -t all -r'

# References

* [1] Functest User Guide: http://docs.opnfv.org/en/latest/submodules/functest/docs/testing/user/userguide/index.html
* [2] Xtesting page: https://wiki.opnfv.org/display/functest/Xtesting
* [3] Onap robot repo: https://git.onap.org/testsuite/
* [4] https://hub.docker.com/r/colvert22/xtesting-onap-robot/
