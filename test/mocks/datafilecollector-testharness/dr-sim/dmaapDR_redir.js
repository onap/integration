var http = require('http');
var https = require('https');

var express = require('express');
const stream = require('stream');
var app = express();
var fs = require("fs");
var path = require('path');
var privateKey  = fs.readFileSync('cert/private.key', 'utf8');
var certificate = fs.readFileSync('cert/certificate.crt', 'utf8');
var credentials = {key: privateKey, cert: certificate};

var bodyParser = require('body-parser')

// parse application/x-www-form-urlencoded
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

app.put('/publish/1/:filename', function (req, res) {
	console.log(req.files);
	console.log(req.body)
	console.log(req.headers)
	var filename = path.basename(req.params.filename);
  filename = path.resolve(__dirname, filename);
	console.log(req.params.filename);
  fs.writeFile(filename, req.body, function (error) {
  	if (error) { console.error(error); }
	});
	 res.send("ok")
})
var httpServer = http.createServer(app);
var httpsServer = https.createServer(credentials, app);

var httpPort=3908
var httpsPort=3909
httpServer.listen(httpPort);
console.log("DR-simulator listening (http) at "+httpPort)
httpsServer.listen(httpsPort);
console.log("DR-simulator listening (https) at "+httpsPort)

