var http = require('http');

var express = require('express');
var app = express();

//I am alive
app.get("/",function(req, res){
	res.send("ok");
})

//Get parameter valuye from other server
function getSimCtr(url, cb) {
    var data = '';
	http.get(url, (resp) => {
  		// A chunk of data has been recieved.
  		resp.on('data', (chunk) => {
    		data += chunk;
  		});

  		// The whole response has been received.
  		resp.on('end', () => {
  			//Pad data to fixed length
  			var i = 20-data.length;
  			while(i>0) {
  				data = data+"&nbsp;";
  				i--;
  			}
    		cb(data);
  		});

	}).on("error", (err) => {
  		console.log("Error: " + err.message);
  		cb("no response");
	});
};

//Status variables, for parameters values fetched from other simulators
var mr1, mr2, mr3, mr4, mr5, mr6, mr7, mr8, mr9, mr10;

var dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8, dr9, dr10;

var drr1, drr2, drr3, drr4, drr5, drr6;

//Heartbeat var
var dfc1;

app.get("/mon",function(req, res){

	//DFC
	getSimCtr("http://127.0.0.1:8100/heartbeat", function(data) {
		dfc1 = data;
    });

	//MR
    getSimCtr("http://127.0.0.1:2222/ctr_requests", function(data) {
    	mr1 = data;
    });
    getSimCtr("http://127.0.0.1:2222/ctr_responses", function(data) {
    	mr2 = data;
    });
    getSimCtr("http://127.0.0.1:2222/ctr_unique_files", function(data) {
    	mr3 = data;
    });
    getSimCtr("http://127.0.0.1:2222/tc_info", function(data) {
    	mr4 = data;
    });
    getSimCtr("http://127.0.0.1:2222/ctr_events", function(data) {
    	mr5 = data;
    });
    getSimCtr("http://127.0.0.1:2222/execution_time", function(data) {
    	mr6 = data;
    });
    getSimCtr("http://127.0.0.1:2222/ctr_unique_PNFs", function(data) {
    	mr7 = data;
    });
    getSimCtr("http://127.0.0.1:2222/exe_time_first_poll", function(data) {
    	mr8 = data;
    });
    getSimCtr("http://127.0.0.1:2222/ctr_files", function(data) {
    	mr9 = data;
    });
    getSimCtr("http://127.0.0.1:2222/status", function(data) {
    	mr10 = data;
    });

    //DR
    getSimCtr("http://127.0.0.1:3906/ctr_publish_query", function(data) {
    	dr1 = data;
    });
    getSimCtr("http://127.0.0.1:3906/ctr_publish_query_published", function(data) {
    	dr2 = data;
    });    
    getSimCtr("http://127.0.0.1:3906/ctr_publish_query_not_published", function(data) {
    	dr3 = data;
    });
    getSimCtr("http://127.0.0.1:3906/ctr_publish_req", function(data) {
    	dr4 = data;
    });
    getSimCtr("http://127.0.0.1:3906/ctr_publish_req_redirect", function(data) {
    	dr5 = data;
    });
    getSimCtr("http://127.0.0.1:3906/ctr_publish_req_published", function(data) {
    	dr6 = data;
    });
    getSimCtr("http://127.0.0.1:3906/ctr_published_files", function(data) {
    	dr7 = data;
    });
    getSimCtr("http://127.0.0.1:3906/tc_info", function(data) {
    	dr8 = data;
    });
    getSimCtr("http://127.0.0.1:3906/execution_time", function(data) {
    	dr9 = data;
    });
    getSimCtr("http://127.0.0.1:3906/ctr_double_publish", function(data) {
    	dr10 = data;
    });

    //DR REDIR
    getSimCtr("http://127.0.0.1:3908/ctr_publish_requests", function(data) {
    	drr1 = data;
    });
    getSimCtr("http://127.0.0.1:3908/ctr_publish_responses", function(data) {
    	drr2 = data;
    });
    getSimCtr("http://127.0.0.1:3908/tc_info", function(data) {
    	drr3 = data;
    });
    getSimCtr("http://127.0.0.1:3908/execution_time", function(data) {
    	drr4 = data;
    });
    getSimCtr("http://127.0.0.1:3908/time_lastpublish", function(data) {
    	drr5 = data;
    });
    getSimCtr("http://127.0.0.1:3908/dwl_volume", function(data) {
    	drr6 = data;
    });

  //Build web page
	var str = "<!DOCTYPE html>" +
          "<html>" +
          "<head>" +
            "<meta http-equiv=\"refresh\" content=\"5\">"+  //5 sec auto reefresh
            "<title>DFC and simulator monitor</title>"+
            "</head>" +
            "<body>" +
            "<h3>DFC</h3>" +
            "<font face=\"Courier New\">"+
            "Heartbeat:....................................." + dfc1 + "<br>" +
            "</font>"+
            "<h3>MR Simulator</h3>" +
            "<font face=\"Courier New\">"+
            "MR TC:........................................." + mr4 + "<br>" +
            "Status:........................................" + mr10 + "<br>" +
            "Execution time (mm.ss):........................" + mr6 + "<br>" +
            "Execution time from first poll (mm.ss):....... " + mr8 + "<br>" +
            "Number of requests (polls):...................." + mr1 + "<br>" +
            "Number of responses (polls):..................." + mr2 + "<br>" +
            "Number of files in all responses:.............." + mr9 + "<br>" +
            "Number of unique files in all responses:......." + mr3 + "<br>" +
            "Number of events..............................." + mr5 + "<br>" +
            "Number of unique PNFs.........................." + mr7 + "<br>" +
            "</font>"+
            "<h3>DR Simulator</h3>" +
            "<font face=\"Courier New\">"+
            "DR TC:........................................." + dr8 + "<br>" +
            "Execution time (mm.ss):........................" + dr9 + "<br>" +
            "Number of queries:............................." + dr1 + "<br>" +
            "Number of query responses, file published:....." + dr2 + "<br>" +
            "Number of query responses, file not published:." + dr3 + "<br>" +
            "Number of requests:............................" + dr4 + "<br>" +
            "Number of responses with redirect:............." + dr5 + "<br>" +
            "Number of responses without redirect:.........." + dr6 + "<br>" +
            "Number of published files:....................." + dr7 + "<br>" +
            "Number of double published files:.............." + dr10 + "<br>" +
            "</font>"+
            "<h3>DR Redirect Simulator</h3>" +
            "<font face=\"Courier New\">"+
            "DR REDIR TC:..................................." + drr3 + "<br>" +
            "Execution time (mm.ss):........................" + drr4 + "<br>" +
            "Number of requests:............................" + drr1 + "<br>" +
            "Number of responses:..........................." + drr2 + "<br>" +
            "Downloaded volume (bytes):....................." + drr6 + "<br>" +
            "Last publish (mm:ss):.........................." + drr5 + "<br>" +
            "</font>"+
           "</body>" +
          "</html>";
	res.send(str);
})

var httpServer = http.createServer(app);
var httpPort=9999;
httpServer.listen(httpPort);
console.log("Simulator monitor listening (http) at "+httpPort);