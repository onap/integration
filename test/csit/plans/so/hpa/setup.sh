#start mariadb
docker run -d --name mariadb -h db.mso.testlab.openecomp.org -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -v ${WORKSPACE}/test/csit/scripts/mariadb/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d  -v ${WORKSPACE}/test/csit/scripts/mariadb/conf.d:/etc/mysql/conf.d nexus3.onap.org:10001/mariadb

#start so
docker run -d --name so -h mso.mso.testlab.openecomp.org -e MYSQL_ROOT_PASSWORD=password --link=mariadb:db.mso.testlab.openecomp.org -p 8080:8080 -v ${WORKSPACE}/test/csit/scripts/so/chef-config:/shared nexus3.onap.org:10001/openecomp/mso:1.1-STAGING-latest


SO_IP=`get-instance-ip.sh so`
# Wait for initialization
for i in {1..10}; do
    curl -sS ${SO_IP}:1080 && break
    echo sleep $i
    sleep $i
done

#REPO_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' so`
REPO_IP='127.0.0.1'
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"
