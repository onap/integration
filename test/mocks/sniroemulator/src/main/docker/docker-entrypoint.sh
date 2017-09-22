#!/bin/bash

touch /app.jar

java -Xms1024m -Xmx1024m -jar /var/wiremock/lib/app.jar