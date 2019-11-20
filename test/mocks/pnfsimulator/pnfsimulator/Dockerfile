FROM openjdk:8-jre-alpine
ADD target/libs /app/libs
ADD target/pnfsimulator-5.0.0-SNAPSHOT.jar /app/pnf-simulator.jar
CMD apk update
CMD apk add ca-certificates
ADD certificates  /usr/local/share/ca-certificates/
RUN update-ca-certificates
CMD java -cp /app/libs/*:/app/pnf-simulator.jar org.onap.pnfsimulator.Main
