var http = require('http');
var https = require('https');

var express = require('express');
const stream = require('stream');
var app = express();
var fs = require("fs");
var path = require('path');
const sleep = (milliseconds) => {
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}
var ArgumentParser = require('argparse').ArgumentParser;
var privateKey  = fs.readFileSync('cert/key.pem', 'utf8');
var certificate = fs.readFileSync('cert/cert.pem', 'utf8');
var credentials = {key: privateKey, cert: certificate};

var total_first_publish=0;
var total_last_publish=0
var total_files=0;
var speed=0;

var feeds="1:A";  //Comma separated list of feedId:filePrefix. Default is feedId=1 and file prefix 'A'
var feedNames=[];
var filePrefixes=[];
var feedIndexes=[];

var bodyParser = require('body-parser')
var startTime = Date.now();

var dr_callback_ip = '192.168.100.2'; //IP for DR when running as container. Can be changed by env DR_SIM_IP

//Counters
var ctr_publish_requests = [];
var ctr_publish_requests_bad_file_prefix = [];
var ctr_publish_responses = [];
var lastPublish = [];
var dwl_volume = [];

var parser = new ArgumentParser({
	version: '0.0.1',
	addHelp:true,
	description: 'Datarouter redirect simulator'
  });

parser.addArgument('--tc' , { help: 'TC $NoOfTc' } );
parser.addArgument('--printtc' ,
	  {
		  help: 'Print complete usage help',
		  action: 'storeTrue'
	  }
  );

var args = parser.parseArgs();
const tc_normal = "normal";
const tc_no_publish ="no_publish"
const tc_10p_no_response = "10p_no_response";
const tc_10first_no_response = "10first_no_response";
const tc_100first_no_response = "100first_no_response";
const tc_all_delay_1s = "all_delay_1s";
const tc_all_delay_10s = "all_delay_10s";
const tc_10p_delay_10s = "10p_delay_10s";
const tc_10p_error_response = "10p_error_response";
const tc_10first_error_response = "10first_error_response";
const tc_100first_error_response = "100first_error_response";

if (args.tc==tc_normal) {
  console.log("TC: " + args.tc)

} else if (args.tc==tc_no_publish) {
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
  console.log("TC " + tc_normal + ": Normal case, all files publish and DR updated");
  console.log("TC " + tc_no_publish + ": Ok response but no files published");
  console.log("TC " + tc_10p_no_response + ": 10% % no response (file not published)");
  console.log("TC " + tc_10first_no_response + ": 10 first requests give no response (files not published)");
  console.log("TC " + tc_100first_no_response + ": 100 first requests give no response (files not published)");
  console.log("TC " + tc_all_delay_1s + ": All responses delayed 1s, normal publish");
  console.log("TC " + tc_all_delay_10s + ": All responses delayed 10s, normal publish");
  console.log("TC " + tc_10p_delay_10s + ": 10% of responses delayed 10s, normal publish");
  console.log("TC " + tc_10p_error_response + ": 10% error response (file not published)");
  console.log("TC " + tc_10first_error_response + ": 10 first requests give error response (file not published)");
  console.log("TC " + tc_100first_error_response + ": 100 first requests give error responses (file not published)");

  process.exit(0);
}

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

// parse application/vnd.api+json as json
app.use(bodyParser.json({ type: 'application/vnd.api+json' }))

// parse some custom thing into a Buffer
app.use(bodyParser.raw({limit:1024*1024*60, type: 'application/octet-stream' }))

// parse an HTML body into a string
app.use(bodyParser.text({ type: 'text/html' }))

//Formatting
function fmtMSS(s){
	return(s-(s%=60))/60+(9<s?':':':0')+s  //Format time diff to mm:ss
}
function fmtLargeNumber(x) {
	return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " "); //Format large with space, eg: 1 000 000
}

//I'm alive function
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

function toCommaListTime(ctrArray) {
	var str="";
	for(i=0;i<feedNames.length;i++) {
		if (i!=0) {
			str=str+",";
		}
		if (ctrArray[i] < 0) {
			str=str+"--:--";
		} else {
			str=str+fmtMSS(ctrArray[i]);
		}
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

function largestInListTime(ctrArray) {
	var tmp=-1;
	var str=""
	for(i=0;i<feedNames.length;i++) {
		if (ctrArray[i] > tmp) {
			tmp = ctrArray[i];
		}
	}
	if (tmp < 0) {
		str="--:--";
	} else {
		str=fmtMSS(tmp);
	}
	return str;
}

//Counter readout
app.get("/ctr_publish_requests",function(req, res){
	res.send(""+sumList(ctr_publish_requests));
})
app.get("/feeds/ctr_publish_requests/",function(req, res){
	res.send(toCommaList(ctr_publish_requests));
})
app.get("/ctr_publish_requests/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_requests[feedIndexes[feedId]]);
})

app.get("/ctr_publish_requests_bad_file_prefix",function(req, res){
	res.send(""+sumList(ctr_publish_requests_bad_file_prefix));
})
app.get("/feeds/ctr_publish_requests_bad_file_prefix/",function(req, res){
	res.send(toCommaList(ctr_publish_requests_bad_file_prefix));
})
app.get("/ctr_publish_requests_bad_file_prefix/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_requests_bad_file_prefix[feedIndexes[feedId]]);
})

app.get("/ctr_publish_responses",function(req, res){
	res.send(""+sumList(ctr_publish_responses));
})
app.get("/feeds/ctr_publish_responses/",function(req, res){
	res.send(toCommaList(ctr_publish_responses));
})
app.get("/ctr_publish_responses/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+ctr_publish_responses[feedIndexes[feedId]]);
})

app.get("/execution_time",function(req, res){
	var diff = fmtMSS(Math.floor((Date.now()-startTime)/1000));
	res.send(""+diff);
})
app.get("/time_lastpublish",function(req, res){
	res.send(""+largestInListTime(lastPublish));
})
app.get("/feeds/time_lastpublish/",function(req, res){
	res.send(toCommaListTime(lastPublish));
})
app.get("/time_lastpublish/:feedId",function(req, res){
	var feedId = req.params.feedId;
	if (lastPublish[feedIndexes[feedId]] < 0) {
		res.send("--:--");
	}
	res.send(""+fmtMSS(lastPublish[feedIndexes[feedId]]));
})

app.get("/dwl_volume",function(req, res){
	res.send(""+fmtLargeNumber(sumList(dwl_volume)));
})
app.get("/feeds/dwl_volume/",function(req, res){
	var str="";
	for(i=0;i<feedNames.length;i++) {
		if (i!=0) {
			str=str+",";
		}
		str=str+fmtLargeNumber(dwl_volume[i]);
	}
	res.send(str);
})
app.get("/dwl_volume/:feedId",function(req, res){
	var feedId = req.params.feedId;
	res.send(""+fmtLargeNumber(dwl_volume[feedIndexes[feedId]]));
})

app.get("/tc_info",function(req, res){
	res.send(args.tc);
})

app.get("/feeds",function(req, res){
	res.send(feeds);
})

app.get("/speed",function(req, res){
	res.send(""+speed);
})

function filenameStartsWith(fileName, feedIndex) {
	var i=0;
	for(i=0;i<filePrefixes[feedIndex].length;i++) {
		var prefix=filePrefixes[feedIndex][i];
		if (fileName.startsWith(prefix)) {
			return true;
		}
	}
	return false;
}

app.put('/publish/:feedId/:filename', function (req, res) {

	console.log(req.url);
	var feedId=req.params.feedId;
//	console.log("First 25 bytes of body: " + req.body.slice(0,25))
	console.log(req.headers)
	ctr_publish_requests[feedIndexes[feedId]]++;
	var filename = req.params.filename;
	if (!filenameStartsWith(filename, feedIndexes[feedId])) {
		ctr_publish_requests_bad_file_prefix[feedIndexes[feedId]]++;
	}
	var ctr = ctr_publish_requests[feedIndexes[feedId]];
	if (args.tc == tc_no_publish) {
		ctr_publish_responses[feedIndexes[feedId]]++;
		res.send("ok")
		return;
	} else if (args.tc==tc_10p_no_response && (ctr%10)==0) {
		return;
	} else if (args.tc==tc_10first_no_response && ctr<11) {
		return;
	} else if (args.tc==tc_100first_no_response && ctr<101) {
		return;
	} else if (args.tc==tc_10p_error_response && (ctr%10)==0) {
		ctr_publish_responses[feedIndexes[feedId]]++;
		res.send(400, "");
		return;
	} else if (args.tc==tc_10first_error_response && ctr<11) {
		ctr_publish_responses[feedIndexes[feedId]]++;
		res.send(400, "");
		return;
	} else if (args.tc==tc_100first_error_response && ctr<101) {
		ctr_publish_responses[feedIndexes[feedId]]++;
		res.send(400, "");
		return;
	}

	//Remaining part if normal file publish

	console.log(filename);
	//Create filename (appending file size and feedid to name) to store
  	var storedFilename = path.resolve(__dirname, filename+"-"+feedId+"-"+req.body.length);
  	fs.writeFile(storedFilename, "", function (error) {  //Store file with zero size
  		if (error) { console.error(error); }
	});

	//Make callback to update list of publish files in DR sim
	//Note the hard code ip-adress, DR sim get this ip if simulators started from the
	//script in the 'simulatorgroup' dir.
	//Work around: Could not get a normal http put to work from nodejs, using curl instead
	var util = require('util');
	var exec = require('child_process').exec;

	var command = 'curl -s -X PUT http://' + dr_callback_ip + ':3906/dr_redir_publish/'+feedId+'/'+filename;

	console.log("Callback to DR sim to report file published, cmd: " + command);
	var child = exec(command, function(error, stdout, stderr){
		console.log('stdout: ' + stdout);
		console.log('stderr: ' + stderr);
		if(error !== null) {
			console.log('exec error: ' + error);
		}
	});

	//Update status variables
	ctr_publish_responses[feedIndexes[feedId]]++;
	lastPublish[feedIndexes[feedId]] = Math.floor((Date.now()-startTime)/1000);
	dwl_volume[feedIndexes[feedId]] = dwl_volume[feedIndexes[feedId]] + req.body.length;

	if (args.tc==tc_10p_delay_10s && (ctr%10)==0) {
        sleep(10000).then(() => {
			res.send("ok");
		});
		return;
	} else if (args.tc==tc_all_delay_10s) {
        sleep(10000).then(() => {
			res.send("ok");
		});
		return;
	}  else if (args.tc==tc_all_delay_1s) {
        sleep(1000).then(() => {
			res.send("ok");
		});
		return;
	}
	if (total_first_publish == 0) {
		total_first_publish=Date.now()/1000;
	}
	total_last_publish=Date.now()/1000;
	total_files++;
	if (total_last_publish > total_first_publish) {
		speed = Math.round((total_files/(total_last_publish-total_first_publish))*10)/10;
	}

	res.send("ok")
});


var httpServer = http.createServer(app);
var httpsServer = https.createServer(credentials, app);

var httpPort=3908
var httpsPort=3909
httpServer.listen(httpPort);
console.log("DR-simulator listening (http) at "+httpPort)
httpsServer.listen(httpsPort);
console.log("DR-simulator listening (https) at "+httpsPort)

if (process.env.DR_SIM_IP) {
	dr_callback_ip=process.env.DR_SIM_IP;
}
console.log("Using IP " + dr_callback_ip + " for callback to DR sim");

if (process.env.DR_REDIR_FEEDS) {
	feeds=process.env.DR_REDIR_FEEDS;
}
console.log("Configured list of feeds: " + feeds);

var i=0;
feedNames=feeds.split(',');
for(i=0;i<feedNames.length;i++) {
	var tmp=feedNames[i].split(':');
	feedNames[i]=tmp[0].trim();
	feedIndexes[feedNames[i]]=i;
	filePrefixes[i]=[]
	var j=0;
	for(j=1;j<tmp.length;j++) {
		filePrefixes[i][j-1]=tmp[j];
	}

	ctr_publish_requests[i] = 0;
	ctr_publish_requests_bad_file_prefix[i] = 0;
	ctr_publish_responses[i] = 0;
	lastPublish[i] = -1;
	dwl_volume[i] = 0;
}
console.log("Parsed mapping between feed id and file name prefix");
for(i=0;i<feedNames.length;i++) {
	var fn = feedNames[i];
	for (j=0;j<filePrefixes[i].length;j++) {
		console.log("Feed id: " + fn + ", file name prefix: " + filePrefixes[i][j]);
	}
}
