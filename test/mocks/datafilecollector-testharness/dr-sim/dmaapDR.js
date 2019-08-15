var http = require('http');
var https = require('https');
var ArgumentParser = require('argparse').ArgumentParser;
var express = require('express');
const stream = require('stream');
var app = express();
var fs = require('fs');
const sleep = (milliseconds) => {
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}
var privateKey  = fs.readFileSync('cert/private.key', 'utf8');
var certificate = fs.readFileSync('cert/certificate.crt', 'utf8');
var credentials = {key: privateKey, cert: certificate};

var feeds="1:A";  //Comma separated list of feedId:filePrefix. Default is feedId=1 and file prefix 'A'
var feedNames=[];
var filePrefixes=[];
var feedIndexes=[];


//For execution time calculation
var startTime = Date.now();

//Test case constants
const tc_normal = "normal";
const tc_none_published = "none_published";
const tc_all_published = "all_published"
const tc_10p_no_response = "10p_no_response";
const tc_10first_no_response = "10first_no_response";
const tc_100first_no_response = "100first_no_response";
const tc_all_delay_1s = "all_delay_1s";
const tc_all_delay_10s = "all_delay_10s";
const tc_10p_delay_10s = "10p_delay_10s";
const tc_10p_error_response = "10p_error_response";
const tc_10first_error_response = "10first_error_response";
const tc_100first_error_response = "100first_error_response";

var drr_sim_ip = 'drsim_redir'; //IP for redirect to DR redir sim. Can be changed by env DRR_SIM_IP

//Counters
var ctr_publish_query = [];
var ctr_publish_query_bad_file_prefix = [];
var ctr_publish_query_published = [];
var ctr_publish_query_not_published = [];
var ctr_publish_req = [];
var ctr_publish_req_bad_file_prefix = [];
var ctr_publish_req_redirect = [];
var ctr_publish_req_published = [];
var ctr_double_publish = [];

//db of published files
var published=[];

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

} else if (args.tc==tc_all_delay_1s) {
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
	console.log("TC " + tc_all_delay_1s + ": All responses delayed 1s (both query and publish).");
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
//Removed-file data not used in this simulator
//app.use(bodyParser.raw({limit:1024*1024*60, type: 'application/octet-stream' }))

// parse an HTML body into a string
app.use(bodyParser.text({ type: 'text/html' }))



//Is alive function
app.get("/",function(req, res){
	res.send("ok");
})

function toCommaList(ctrArray) {
	var str="";
	for(i=0;i<feedNames.length;i++) {
		if (i!=0) {
			str=str+",";
		}
		str=str+ctrArray[i];
	}
	return str;
}

function sumList(ctrArray) {
	var tmp=0;
	for(i=0;i<feedNames.length;i++) {
		tmp=tmp+ctrArray[i];
	}
	return ""+tmp;
}

function sumListLength(ctrArray) {
	var tmp=0;
	for(i=0;i<feedNames.length;i++) {
		tmp=tmp+ctrArray[i].length;
	}
	return ""+tmp;
}

//Counter readout
app.get("/ctr_publish_query",function(req, res){
	res.send(""+sumList(ctr_publish_query));
})
app.get("/feeds/ctr_publish_query",function(req, res){
	res.send(toCommaList(ctr_publish_query));
})
app.get("/ctr_publish_query/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_query[feedIndexes[feedId]]);
})

app.get("/ctr_publish_query_bad_file_prefix",function(req, res){
	res.send(""+sumList(ctr_publish_query_bad_file_prefix));
})
app.get("/feeds/ctr_publish_query_bad_file_prefix",function(req, res){
	res.send(toCommaList(ctr_publish_query_bad_file_prefix));
})
app.get("/ctr_publish_query_bad_file_prefix/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_query_bad_file_prefix[feedIndexes[feedId]]);
})

app.get("/ctr_publish_query_published",function(req, res){
	res.send(""+sumList(ctr_publish_query_published));
})
app.get("/feeds/ctr_publish_query_published",function(req, res){
	res.send(toCommaList(ctr_publish_query_published));
})
app.get("/ctr_publish_query_published/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_query_published[feedIndexes[feedId]]);
})

app.get("/ctr_publish_query_not_published",function(req, res){
	res.send(""+sumList(ctr_publish_query_not_published));
})
app.get("/feeds/ctr_publish_query_not_published",function(req, res){
	res.send(toCommaList(ctr_publish_query_not_published));
})
app.get("/ctr_publish_query_not_published/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_query_not_published[feedIndexes[feedId]]);
})

app.get("/ctr_publish_req",function(req, res){
	res.send(""+sumList(ctr_publish_req));
})
app.get("/feeds/ctr_publish_req",function(req, res){
	res.send(toCommaList(ctr_publish_req));
})
app.get("/ctr_publish_req/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_req[feedIndexes[feedId]]);
})

app.get("/ctr_publish_req_bad_file_prefix",function(req, res){
	res.send(""+sumList(ctr_publish_req_bad_file_prefix));
})
app.get("/feeds/ctr_publish_req_bad_file_prefix",function(req, res){
	res.send(toCommaList(ctr_publish_req_bad_file_prefix));
})
app.get("/ctr_publish_req_bad_file_prefix/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_req_bad_file_prefix[feedIndexes[feedId]]);
})

app.get("/ctr_publish_req_redirect",function(req, res){
	res.send(""+sumList(ctr_publish_req_redirect));
})
app.get("/feeds/ctr_publish_req_redirect",function(req, res){
	res.send(toCommaList(ctr_publish_req_redirect));
})
app.get("/ctr_publish_req_redirect/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_req_redirect[feedIndexes[feedId]]);
})

app.get("/ctr_publish_req_published",function(req, res){
	res.send(""+sumList(ctr_publish_req_published));
})
app.get("/feeds/ctr_publish_req_published",function(req, res){
	res.send(toCommaList(ctr_publish_req_published));
})
app.get("/ctr_publish_req_published/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_req_published[feedIndexes[feedId]]);
})

app.get("/ctr_published_files",function(req, res){
	res.send(""+sumListLength(published));
})
app.get("/feeds/ctr_published_files",function(req, res){
	var str="";
	for(i=0;i<feedNames.length;i++) {
		if (i!=0) {
			str=str+",";
		}
		str=str+published[i].length;
	}
	res.send(str);
})
app.get("/ctr_published_files/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+published[feedIndexes[feedId]].length);
})

app.get("/tc_info",function(req, res){
	res.send(args.tc);
})
app.get("/ctr_double_publish",function(req, res){
	res.send(""+sumList(ctr_double_publish));
})
app.get("/feeds/ctr_double_publish",function(req, res){
	var str="";
	for(i=0;i<feedNames.length;i++) {
		if (i!=0) {
			str=str+",";
		}
		str=str+ctr_double_publish[i];
	}
	res.send(str);
})
app.get("/ctr_double_publish/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_double_publish[feedIndexes[feedId]]);
})

function fmtMSS(s){
	return(s-(s%=60))/60+(9<s?':':':0')+s    //Format time diff in mm:ss
}
app.get("/execution_time",function(req, res){
	var diff = fmtMSS(Math.floor((Date.now()-startTime)/1000));
	res.send(""+diff);
})
app.get("/feeds",function(req, res){
	res.send(feeds);
})

function filenameStartsWith(fileName, feedIndex) {
	for(i=0;i<filePrefixes[feedIndex].length;i++) {
		var prefix=filePrefixes[feedIndex][i];
		if (fileName.startsWith(prefix)) {
			return true;
		}
	}
	return false;
}

app.get('/feedlog/:feedId',function(req, res){
	console.log("url:"+req.url);
	var feedId = req.params.feedId;
	ctr_publish_query[feedIndexes[feedId]]++;
	var filename = req.query.filename;
	if (!filenameStartsWith(filename, feedIndexes[feedId])) {
		ctr_publish_query_bad_file_prefix[feedIndexes[feedId]]++;
	}
	console.log(filename);
	var qtype = req.query.type;
	if(typeof(filename) == 'undefined'){
		res.status(400).send({error: 'No filename provided.'});
		return;
	} else if(typeof(qtype) == 'undefined'){
		res.status(400).send({error: 'No type provided.'});
		return;
	}
	var ctr = ctr_publish_query[feedIndexes[feedId]];
	//Ugly fix, plus signs replaces with spaces in query params....need to put them back
	filename = filename.replace(/ /g,"+");

	var sleeptime=0;
	if (args.tc==tc_normal) {
		sleeptime=0;
	} else if (args.tc==tc_10p_no_response && (ctr%10) == 0) {
		return;
	} else if (args.tc==tc_10first_no_response && ctr<11) {
		return;
	} else if (args.tc==tc_100first_no_response && ctr<101) {
		return;
	} else if (args.tc==tc_all_delay_1s) {
		sleeptime=1000;
	} else if (args.tc==tc_all_delay_10s) {
		sleeptime=10000;
	} else if (args.tc==tc_10p_delay_10s && (ctr%10) == 0) {
		sleeptime=10000;
	} else if (args.tc==tc_10p_error_response && (ctr%10) == 0) {
		res.send(400);
		return;
	} else if (args.tc==tc_10first_error_response && ctr<11) {
		res.send(400);
		return;
	} else if (args.tc==tc_100first_error_response & ctr<101) {
		res.send(400);
		return;
	}

	if (published[feedIndexes[feedId]].includes(filename)) {
		ctr_publish_query_published[feedIndexes[feedId]]++;
		strToSend="[" + filename + "]";
	} else {
		ctr_publish_query_not_published[feedIndexes[feedId]]++;
		strToSend="[]";
	}
	if (sleeptime > 0) {
		sleep(sleeptime).then(() => {
			res.send(strToSend);
		});
	} else {
		res.send(strToSend);
	}
});


app.put('/publish/:feedId/:filename', function (req, res) {
	console.log("url:"+req.url);
//	console.log("body (first 25 bytes):"+req.body.slice(0,25));
	console.log("headers:"+req.headers);
	console.log(JSON.stringify(req.headers));
	var feedId = req.params.feedId;
	ctr_publish_req[feedIndexes[feedId]]++;

	var filename = req.params.filename;
	console.log(filename);
	if (!filenameStartsWith(filename, feedIndexes[feedId])) {
		ctr_publish_req_bad_file_prefix[feedIndexes[feedId]]++;
	}
    var ctr = ctr_publish_req[feedIndexes[feedId]];
	if (args.tc==tc_normal) {
	// Continue
	} else if (args.tc==tc_none_published) {
		ctr_publish_req_redirect[feedIndexes[feedId]]++;
		res.redirect(301, 'http://' + drr_sim_ip + ':3908/publish/'+feedId+'/'+filename);
		return;
	} else if (args.tc==tc_all_published) {
		ctr_publish_req_published[feedIndexes[feedId]]++;
		res.send("ok");
		return;
	}else if (args.tc==tc_10p_no_response && (ctr%10) == 0) {
		return;
	} else if (args.tc==tc_10first_no_response && ctr<11) {
		return;
	} else if (args.tc==tc_100first_no_response && ctr<101) {
		return;
	} else if (args.tc==tc_all_delay_1s) {
		do_publish_delay(res, filename, 1000, feedId);
		return;
	} else if (args.tc==tc_all_delay_10s) {
		do_publish_delay(res, filename, 10000, feedId);
		return;
	} else if (args.tc==tc_10p_delay_10s && (ctr%10) == 0) {
		do_publish_delay(res, filename, 10000, feedId);
		return;
	} else if (args.tc==tc_10p_error_response && (ctr%10) == 0) {
		res.send(400);
		return;
	} else if (args.tc==tc_10first_error_response && ctr<11) {
		res.send(400);
		return;
	} else if (args.tc==tc_100first_error_response & ctr<101) {
		res.send(400);
		return;
	}
	if (!published.includes(filename)) {
		ctr_publish_req_redirect[feedIndexes[feedId]]++;
		res.redirect(301, 'http://'+drr_sim_ip+':3908/publish/'+feedId+'/'+filename);
	} else {
		ctr_publish_req_published[feedIndexes[feedId]]++;
		res.send("ok");
	}
	return;
})

function do_publish_delay(res, filename, sleeptime, feedId) {
	if (!published.includes(filename)) {
		ctr_publish_req_redirect[feedIndexes[feedId]]++;
		sleep(1000).then(() => {
			res.redirect(301, 'http://'+drr_sim_ip+':3908/publish/'+feedId+'/'+filename);
		});
	} else {
		ctr_publish_req_published[feedIndexes[feedId]]++;
		sleep(1000).then(() => {
			res.send("ok");
		});
	}
}

//Callback from DR REDIR server, when file is published ok this PUT request update the list of published files.
app.put('/dr_redir_publish/:feedId/:filename', function (req, res) {
	console.log("url:"+req.url);
	var feedId = req.params.feedId;
	var filename = req.params.filename;
	console.log(filename);

	if (!published[feedIndexes[feedId]].includes(filename)) {
		console.log("File marked as published by callback from DR redir SIM. url: " + req.url);
		published[feedIndexes[feedId]].push(filename);
	} else {
		console.log("File already marked as published. Callback from DR redir SIM. url: " + req.url);
		ctr_double_publish[feedIndexes[feedId]]++;
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

if (process.env.DRR_SIM_IP) {
	drr_sim_ip=process.env.DRR_SIM_IP;
}
console.log("Using IP " + drr_sim_ip + " for redirect to DR redir sim");

if (process.env.DR_FEEDS) {
	feeds=process.env.DR_FEEDS;
}

console.log("Configured list of feeds mapped to file name prefixes: " + feeds);

feedNames=feeds.split(',');
for(i=0;i<feedNames.length;i++) {
	var tmp=feedNames[i].split(':');
	feedNames[i]=tmp[0].trim();
	feedIndexes[feedNames[i]]=i;
	filePrefixes[i]=[]
	for(j=1;j<tmp.length;j++) {
		filePrefixes[i][j-1]=tmp[j];
	}

    ctr_publish_query[i] = 0;
    ctr_publish_query_published[i] = 0;
    ctr_publish_query_not_published[i] = 0;
    ctr_publish_req[i] = 0;
    ctr_publish_req_redirect[i] = 0;
    ctr_publish_req_published[i] = 0;
    ctr_double_publish[i] = 0;
    ctr_publish_query_bad_file_prefix[i] = 0;
	ctr_publish_req_bad_file_prefix[i] = 0;
	published[i] = [];
}

console.log("Parsed mapping between feed id and file name prefix");
for(i=0;i<feedNames.length;i++) {
	var fn = feedNames[i];
	for (j=0;j<filePrefixes[i].length;j++) {
		console.log("Feed id: " + fn + ", file name prefix: " + filePrefixes[i][j]);
	}
}

