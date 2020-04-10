# ONAP Integration > Bootstrap > Jenkins

This directory contains a set of vagrant scripts that will automatically set up a Jenkins instance
with predefined jobs to build all ONAP java code and docker images.

This is intended to show a beginning ONAP developer how to set up and configure an environment that
can successfully build ONAP code from scratch.  It is not intended to be used as a production
Jenkins CI/CD environment.

NOTE: the Jenkins instance is by default NOT SECURED, with the default admin user and password as "jenkins".
