FROM openjdk:8-jre-alpine

MAINTAINER Geora Barsky <georab@amdocs.com>

# need bash as most scripts expect it
RUN apk --no-cache add bash

RUN mkdir -p /var/wiremock/lib/ 

COPY sniroemulator.jar /var/wiremock/lib/app.jar

WORKDIR /home/wiremock

COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

VOLUME /home/wiremock
EXPOSE 8080 8081 9999

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java", "-jar","/var/wiremock/lib/app.jar"]