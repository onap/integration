## Local development shortcuts:

To start listening on port 10000 for test purposes:

```
nc -l -k -p 10000
```

Test the command above: 

```
echo "Hello World" | nc localhost  10000
```

Trigger the pnf simulator locally:

```
~/dev/git/integration/test/mocks/mass-pnf-sim/pnf-sim-lightweight$ curl -s -X POST -H "Content-Type: application/json" -H "X-ONAP-RequestID: 123" -H "X-InvocationID: 456" -d @config/config.json 
http://localhost:5000/simulator/start
```

## VES event sending

the default action is to send a VES Message every 15 minutes and the total duration of the VES FileReady Message sending is 1 day (these values can be changed in config/config.json)

Message from the stdout of nc:

```
POST / HTTP/1.1
Content-Type: application/json
X-ONAP-RequestID: 123
X-InvocationID: 3a256e95-2594-4b11-b25c-68c4baeb5c20
Content-Length: 734
Host: localhost:10000
Connection: Keep-Alive
User-Agent: Apache-HttpClient/4.5.5 (Java/1.8.0_162)
Accept-Encoding: gzip,deflate
```

```i
javascript
{"event":{"commonEventHeader":{"startEpochMicrosec":"1551865758690","sourceId":"val13","eventId":"registration_51865758",
"nfcNamingCode":"oam","internalHeaderFields":{},"priority":"Normal","version":"4.0.1","reportingEntityName":"NOK6061ZW3",
"sequence":"0","domain":"notification","lastEpochMicrosec":"1551865758690","eventName":"pnfRegistration_Nokia_5gDu",
"vesEventListenerVersion":"7.0.1","sourceName":"NOK6061ZW3","nfNamingCode":"gNB"},
"notificationFields":{"notificationFieldsVersion":"2.0","changeType":"FileReady","changeIdentifier":"PM_MEAS_FILES",
"arrayOfNamedHashMap":[{"name":"10MB.tar.gz","hashMap":{
"location":"ftpes://10.11.0.68/10MB.tar.gz","fileFormatType":"org.3GPP.32.435#measCollec",
"fileFormatVersion":"V10","compression":"gzip"}}]}}}
```
