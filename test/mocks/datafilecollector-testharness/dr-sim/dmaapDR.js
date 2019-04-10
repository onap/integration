var http = require('http');
var https = require('https');
var ArgumentParser = require('argparse').ArgumentParser;
var express = require('express');
const stream = require('stream');
var app = express();
var fs = require('fs');
var privateKey  = fs.readFileSync('cert/private.key', 'utf8');
var certificate = fs.readFileSync('cert/certificate.crt', 'utf8');
var credentials = {key: privateKey, cert: certificate};

//For execution time calculation
var startTime = Date.now();

//Test case constants
const tc_normal = "normal";
const tc_none_published = "none_published";
const tc_all_published = "all_published"
const tc_10p_no_response = "10p_no_response";
const tc_10first_no_response = "10first_no_response";
const tc_100first_no_response = "100first_no_response";
const tc_all_delay_10s = "all_delay_10s";
const tc_10p_delay_10s = "10p_delay_10s";
const tc_10p_error_response = "10p_error_response";
const tc_10first_error_response = "10first_error_response";
const tc_100first_error_response = "100first_error_response";

//Counters
var ctr_publish_query = 0;
var ctr_publish_query_published = 0;
var ctr_publish_query_not_published = 0;
var ctr_publish_req = 0;
var ctr_publish_req_redirect = 0;
var ctr_publish_req_published = 0;

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

if (args.tc==tc_normal) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_none_published) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_all_published) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_10p_no_response) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_10first_no_response) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_100first_no_response) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_all_delay_10s) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_10p_delay_10s) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_10p_error_response) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_10first_error_response) {
	console.log("TC: " + args.tc)

} else if (args.tc==tc_100first_error_response) {
	console.log("TC: " + args.tc)
} else {
	console.log("No TC specified, use: --tc <tc-id>");
	process.exit(0);
}

if (args.printtc) {
	console.log("TC " + tc_normal + ": Normal case, query respone based on published files. Publish responde with ok/redirect depending on if file is published or not.");
	console.log("TC " + tc_none_published + ": Query responde 'ok'. Publish respond with redirect.");
	console.log("TC " + tc_all_published + ": Query respond with filename. Publish respond with 'ok'.");
	console.log("TC " + tc_10p_no_response + ": 10% % no response for query and publish. Otherwise normal case.");
	console.log("TC " + tc_10first_no_response + ": 10 first queries and requests gives no response for query and publish. Otherwise normal case.");
	console.log("TC " + tc_100first_no_response + ": 100 first queries and requests gives no response for query and publish. Otherwise normal case.");
	console.log("TC " + tc_all_delay_10s + ": All responses delayed 10s (both query and publish).");
	console.log("TC " + tc_10p_delay_10s + ": 10% of responses delayed 10s, (both query and publish).");
	console.log("TC " + tc_10p_error_response + ": 10% error response for query and publish. Otherwise normal case.");
	console.log("TC " + tc_10first_error_response + ": 10 first queries and requests gives no response for query and publish. Otherwise normal case.");
	console.log("TC " + tc_100first_error_response + ": 100 first queries and requests gives no response for query and publish. Otherwise normal case.");

	process.exit(0);
  }


var bodyParser = require('body-parser')
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

// parse application/vnd.api+json as json
app.use(bodyParser.json({ type: 'application/vnd.api+json' }))

// parse some custom thing into a Buffer (to cater for 60MB files)
app.use(bodyParser.raw({limit:1024*1024*60, type: 'application/octet-stream' }))
// parse an HTML body into a string
app.use(bodyParser.text({ type: 'text/html' }))



//Is alive function
app.get("/",function(req, res){
	res.send("ok");
})

//Counter readout
app.get("/ctr_publish_query",function(req, res){
	res.send(""+ctr_publish_query);
})
app.get("/ctr_publish_query_published",function(req, res){
	res.send(""+ctr_publish_query_published);
})
app.get("/ctr_publish_query_not_published",function(req, res){
	res.send(""+ctr_publish_query_not_published);
})
app.get("/ctr_publish_req",function(req, res){
	res.send(""+ctr_publish_req);
})
app.get("/ctr_publish_req_redirect",function(req, res){
	res.send(""+ctr_publish_req_redirect);
})
app.get("/ctr_publish_req_published",function(req, res){
	res.send(""+ctr_publish_req_published);
})
app.get("/ctr_published_files",function(req, res){
	res.send(""+published.length);
})
app.get("/tc_info",function(req, res){
	res.send(args.tc);
})
function fmtMSS(s){
	return(s-(s%=60))/60+(9<s?':':':0')+s    //Format time diff in mm:ss
}
app.get("/execution_time",function(req, res){
	diff = fmtMSS(Math.floor((Date.now()-startTime)/1000));
	res.send(""+diff);
})

//db of published files
var published = [];

app.get('/feedlog/1/',function(req, res){
	console.log("url:"+req.url);
	ctr_publish_query++;
	var filename = req.query.filename;
	console.log(filename);
	var qtype = req.query.type;
	if(typeof(filename) == 'undefined'){
		res.status(400).send({error: 'No filename provided.'});
		return;
	} else if(typeof(qtype) == 'undefined'){
		res.status(400).send({error: 'No type provided.'});
		return;
	}
	
	//Ugly fix, plus signs replaces with spaces in query params....need to put them back
	filename = filename.replace(/ /g,"+");
	
	if (args.tc==tc_normal) {
	  //continue
	}  else if (args.tc==tc_none_published) {
		ctr_publish_query_not_published++;
		res.send("[]");
		return;
	} else if (args.tc==tc_all_published) {
		ctr_publish_query_published++;
		res.send("[" + filename + "]");
		return;
	} else if (args.tc==tc_10p_no_response && (ctr_publish_query%10) == 0) {
		return;
	} else if (args.tc==tc_10first_no_response && ctr_publish_query<11) {
		return;
	} else if (args.tc==tc_100first_no_response && ctr_publish_query<101) {
		return;
	} else if (args.tc==tc_all_delay_10s) {
		console.log("sleep begin");
		timer(10000).then(_=>console.log("sleeping done")); 
	} else if (args.tc==tc_10p_delay_10s && (ctr_publish_query%10) == 0) {
		console.log("sleep begin");
		timer(10000).then(_=>console.log("sleeping done")); 
	} else if (args.tc==tc_10p_error_response && (ctr_publish_query%10) == 0) {
		res.send(400);
		return;
	} else if (args.tc==tc_10first_error_response && ctr_publish_query<11) {
		res.send(400);
		return;
	} else if (args.tc==tc_100first_error_response & ctr_publish_query<101) {
		res.send(400);
		return;
	}

	if (published.includes(filename)) {
		ctr_publish_query_published++;
		res.send("[" + filename + "]");
	} else {
		ctr_publish_query_not_published++;
		res.send("[]");
	}
})

app.put('/publish/1/:filename', function (req, res) {
	console.log("url:"+req.url);
	console.log("body (first 25 bytes):"+req.body.slice(0,25));
	console.log("headers:"+req.headers);
	ctr_publish_req++;

	var filename = req.params.filename;
	console.log(filename);

	if (args.tc==tc_normal) {
	    //continue
	} else if (args.tc==tc_none_published) {
		ctr_publish_req_redirect++;
		res.redirect(301, 'http://127.0.0.1:3908/publish/1/'+filename);
		return;
	} else if (args.tc==tc_all_published) {
		ctr_publish_req_published++;
		res.send("ok");
		return;
	}else if (args.tc==tc_10p_no_response && (ctr_publish_req%10) == 0) {
		return;
	} else if (args.tc==tc_10first_no_response && ctr_publish_req<11) {
		return;
	} else if (args.tc==tc_100first_no_response && ctr_publish_req<101) {
		return;
	} else if (args.tc==tc_all_delay_10s) {
		console.log("sleep begin");
		timer(10000).then(_=>console.log("sleeping done")); 
	} else if (args.tc==tc_10p_delay_10s && (ctr_publish_req%10) == 0) {
		console.log("sleep begin");
		timer(10000).then(_=>console.log("sleeping done")); 
	} else if (args.tc==tc_10p_error_response && (ctr_publish_req%10) == 0) {
		res.send(400);
		return;
	} else if (args.tc==tc_10first_error_response && ctr_publish_req<11) {
		res.send(400);
		return;
	} else if (args.tc==tc_100first_error_response & ctr_publish_req<101) {
		res.send(400);
		return;
	}

	if (!published.includes(filename)) {
		ctr_publish_req_redirect++;
		res.redirect(301, 'http://127.0.0.1:3908/publish/1/'+filename);
	} else {
		ctr_publish_req_published++;
		res.send("ok");
	}
})

//Callback from DR REDIR server, when file is published ok this PUT request update the list of published files.
app.put('/dr_redir_publish/:filename', function (req, res) {
	console.log("url:"+req.url);
	var filename = req.params.filename;
	console.log(filename);

	if (!published.includes(filename)) {
		console.log("File marked as published by callback from DR redir SIM. url: " + req.url);
		published.push(filename);
	} else {
		console.log("File already marked as published. Callback from DR redir SIM. url: " + req.url);
	}

	res.send("ok");
})

var httpServer = http.createServer(app);
var httpsServer = https.createServer(credentials, app);

var httpPort=3906;
var httpsPort=3907;
httpServer.listen(httpPort);
console.log("DR-simulator listening (http) at "+httpPort);
httpsServer.listen(httpsPort);
console.log("DR-simulator listening (https) at "+httpsPort);