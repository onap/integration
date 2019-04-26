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
var privateKey  = fs.readFileSync('cert/private.key', 'utf8');
var certificate = fs.readFileSync('cert/certificate.crt', 'utf8');
var credentials = {key: privateKey, cert: certificate};


var bodyParser = require('body-parser')
var startTime = Date.now();

var dr_callback_ip = '192.168.100.2'; //IP for DR when running as container. Can be changed by env DR_SIM_IP

//Counters
var ctr_publish_requests = 0;
var ctr_publish_responses = 0;
var lastPublish = "";
var dwl_volume = 0;

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

//Counter readout
app.get("/ctr_publish_requests",function(req, res){
	res.send(""+ctr_publish_requests);
})
app.get("/ctr_publish_responses",function(req, res){
	res.send(""+ctr_publish_responses);
})
app.get("/execution_time",function(req, res){
	diff = fmtMSS(Math.floor((Date.now()-startTime)/1000));
	res.send(""+diff);
})
app.get("/time_lastpublish",function(req, res){
	res.send(""+lastPublish);
})
app.get("/dwl_volume",function(req, res){
	res.send(""+fmtLargeNumber(dwl_volume));
})
app.get("/tc_info",function(req, res){
	res.send(args.tc);
})

app.put('/publish/1/:filename', function (req, res) {
	console.log(req.url);
	console.log("First 25 bytes of body: " + req.body.slice(0,25))
	console.log(req.headers)
	ctr_publish_requests++;
	if (args.tc == tc_no_publish) {
		tr_publish_responses++;
		res.send("ok")
		return;
	} else if (args.tc==tc_10p_no_response && (ctr_publish_requests%10)==0) {
		return;
	} else if (args.tc==tc_10first_no_response && ctr_publish_requests<11) {
		return;
	} else if (args.tc==tc_100first_no_response && ctr_publish_requests<101) {
		return;
	} else if (args.tc==tc_10p_error_response && (ctr_publish_requests%10)==0) {
		tr_publish_responses++;
		res.send(400, "");
		return;
	} else if (args.tc==tc_10first_error_response && ctr_publish_requests<11) {
		tr_publish_responses++;
		res.send(400, "");
		return;
	} else if (args.tc==tc_100first_error_response && ctr_publish_requests<101) {
		tr_publish_responses++;
		res.send(400, "");
		return;
	}

	//Remaining part if normal file publish

	var filename = req.params.filename;
	console.log(filename);
	//Create filename (appending file size to name) to store
  	var storedFilename = path.resolve(__dirname, filename+"-"+req.body.length); 
  	fs.writeFile(storedFilename, "", function (error) {  //Store file with zero size
  		if (error) { console.error(error); }
	});
	
	//Make callback to update list of publish files in DR sim
	//Note the hard code ip-adress, DR sim get this ip if simulators started from the
	//script in the 'simulatorgroup' dir.
	//Work around: Could not get a normal http put to work from nodejs, using curl instead
	var util = require('util');
	var exec = require('child_process').exec;

	var command = 'curl -s -X PUT http://' + dr_callback_ip + ':3906/dr_redir_publish/' +req.params.filename;

	console.log("Callback to DR sim to report file published, cmd: " + command);
	child = exec(command, function(error, stdout, stderr){
		console.log('stdout: ' + stdout);
		console.log('stderr: ' + stderr);
		if(error !== null) {
			console.log('exec error: ' + error);
		}
		
	});

	//Update status variables
	ctr_publish_responses++;
	lastPublish = fmtMSS(Math.floor((Date.now()-startTime)/1000));
	dwl_volume = dwl_volume + req.body.length;

	if (args.tc==tc_10p_delay_10s && (ctr_publish_requests%10)==0) {
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
