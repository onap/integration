FROM openjdk:8-jre-alpine
ADD libs /app/libs
ADD netconfsimulator-5.0.0-SNAPSHOT.jar /app/netconf-simulator.jar
CMD java -cp /app/libs/*:/app/netconf-simulator.jar org.onap.netconfsimulator.Main
