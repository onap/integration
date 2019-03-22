var http = require('http');
var https = require('https');
var ArgumentParser = require('argparse').ArgumentParser;
var express = require('express');
const stream = require('stream');
var app = express();
var fs = require("fs");
var path = require('path');
var privateKey = fs.readFileSync('cert/private.key', 'utf8');
var certificate = fs.readFileSync('cert/certificate.crt', 'utf8');
var credentials = {
	key: privateKey,
	cert: certificate
};


var parser = new ArgumentParser({
	version: '0.0.1',
	addHelp: true,
	description: 'Datarouter simulator'
});

parser.addArgument('--tc', {
	help: 'TC $NoOfTc'
});
parser.addArgument('--printtc', {
	help: 'Print complete usage help',
	action: 'storeTrue'
});

var args = parser.parseArgs();

if (args.tc == "100") {
	console.log("TC: 100")
}
if (args.tc == "101") {
	console.log("TC: 101")
	//preparations
}
if (args.tc == "102") {
	console.log("TC: 102")
	//preparations
}

if (args.printtc) {
	console.log("TC 100: receive all incoming files");
	console.log("TC 101: drop/deny first 10 publishing attempt, then receive all");
	console.log("TC 102: drop/deny/every second publisging attempt");
	process.exit(0);
}

var bodyParser = require('body-parser')
app.use(bodyParser.urlencoded({
	extended: false
}))

// parse application/json
app.use(bodyParser.json())

// parse application/vnd.api+json as json
app.use(bodyParser.json({
	type: 'application/vnd.api+json'
}))

// parse some custom thing into a Buffer
app.use(bodyParser.raw({
	limit: 1024 * 1024 * 20,
	type: 'application/octet-stream'
}))
// parse an HTML body into a string
app.use(bodyParser.text({
	type: 'text/html'
}))
app.get("/", function (req, res) {
	res.send("ok");
})
app.post('/webapi/feeds/', function (req, res) {
	res.setHeader('Content-Type', 'application/json');
	var feedName = req.body.feedName;
	console.log(feedName);
	res.end(JSON.stringify({
		"type": "feed",
		"lastMod": "2019-03-21T16:00:40.489",
		"status": "VALID",
		"asprClassification": "unclassified",
		"feedDescription": "generated for CSIT",
		"feedId": "3",
		"feedName": feedName,
		"feedVersion": "csit",
		"logURL": "https://dmaap-dr-prov/feedlog/3",
		"owner": "dgl",
		"publishURL": "https://dmaap-dr-prov/publish/3",
		"pubs": [{
			"lastMod": "2019-01-24T16:00:40.484",
			"status": "VALID",
			"dcaeLocationName": "san-francisco",
			"feedId": "3",
			"pubId": "3.4gh53",
			"username": "tmp_i63w8psh6ycnoqu",
			"userpwd": "6jkc1uwywrc8q4w"
		}],
		"subs": [],
		"subscribeURL": "https://dmaap-dr-prov/subscribe/3",
		"suspended": false
	}));
})
var httpServer = http.createServer(app);
var httpsServer = https.createServer(credentials, app);

var httpPort = 6665
var httpsPort = 6666
httpServer.listen(httpPort);
console.log("DR-simulator listening (http) at " + httpPort)
httpsServer.listen(httpsPort);
console.log("DR-simulator listening (https) at " + httpsPort)