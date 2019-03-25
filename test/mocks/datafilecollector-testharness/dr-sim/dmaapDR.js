var http = require('http');
var https = require('https');
var ArgumentParser = require('argparse').ArgumentParser;
var express = require('express');
const stream = require('stream');
var app = express();
var fs = require('fs');
var path = require('path');
var privateKey  = fs.readFileSync('cert/private.key', 'utf8');
var certificate = fs.readFileSync('cert/certificate.crt', 'utf8');
var credentials = {key: privateKey, cert: certificate};
const allPublished = "allPublished";
const nonePublished = "nonePublished";

var parser = new ArgumentParser({
	  version: '0.0.1',
	  addHelp:true,
	  description: 'Datarouter simulator'
	});

parser.addArgument('--tc' , { help: 'TC $NoOfTc' } );
parser.addArgument('--printtc' ,
		{
			help: 'Print complete usage help',
			action: 'storeTrue'
		}
	);

var args = parser.parseArgs();

if (args.tc=="nonePublished") {
	console.log("TC: nonePublished")
}
if (args.tc=="allPublished") {
	console.log("TC: allPublished")
	//preparations
}

if (args.printtc) {
	console.log("TC nonePublished: no file has already been published.");
	console.log("TC allPublished: whatever is the request, this file is considered as published.");
	console.log("No argument passed: normal behaviour, that is publish if not already published");
	process.exit(0);
}

var bodyParser = require('body-parser')
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

// parse application/vnd.api+json as json
app.use(bodyParser.json({ type: 'application/vnd.api+json' }))

// parse some custom thing into a Buffer
app.use(bodyParser.raw({limit:1024*1024*20, type: 'application/octet-stream' }))
// parse an HTML body into a string
app.use(bodyParser.text({ type: 'text/html' }))
app.get("/",function(req, res){
	res.send("ok");
})


var published = [];
app.get('/feedlog/1/',function(req, res){
	var filename = req.query.filename;
	if(args.tc == allPublished){
		res.send("[" + filename + "]");
	} else if(args.tc == nonePublished){
		res.send("[]");
	} else {
		if (published.includes(filename)) {
			res.send("[" + filename + "]");
		} else {
			res.send("[]");
		}
	}
})


app.put('/publish/1/', function (req, res) {
	var filename = req.query.filename;
	var type = req.query.type;
	if(typeof(filename) == 'undefined'){
		res.status(400).send({error: 'No filename provided.'});
	} else if(typeof(type) == 'undefined'){
		res.status(400).send({error: 'No type provided.'});
	} else {
		if(args.tc == allPublished){
			res.send("[" + filename + "]");
		} else if(args.tc == nonePublished){
			res.redirect(301, 'http://127.0.0.1:3908/publish/1/'+filename);
		} else {
			if (!published.includes(filename)) {
				published.push(filename);
				res.redirect(301, 'http://127.0.0.1:3908/publish/1/'+filename);
			} else {
				res.send("ok");
			}
		}
	}
})


var httpServer = http.createServer(app);
var httpsServer = https.createServer(credentials, app);

var httpPort=3906;
var httpsPort=3907;
httpServer.listen(httpPort);
console.log("DR-simulator listening (http) at "+httpPort);
httpsServer.listen(httpsPort);
console.log("DR-simulator listening (https) at "+httpsPort);