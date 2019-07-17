// Sim mon server - query the simulators for counters and other data
// Presents a web page on localhost:9999/mon

var http = require('http');

var express = require('express');
var app = express();
var fieldSize=32;

var dfcHeadings=[];
var dfcVal=[];

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
    		cb(data);
  		});

	}).on("error", (err) => {
  		console.log("Error: " + err.message);
  		cb("no response");
	});
};


//Format a comma separated list of data to a html-safe string with fixed fieldsizes
function formatDataRow(commaList) {
	var str = "";
	var tmp=commaList.split(',');
    for(i=0;i<tmp.length;i++) {
        data=tmp[i];
        var len = fieldSize-data.length;
        while(len>0) {
            data = data+"&nbsp;";
            len--;
        }
        str=str+data+"&nbsp;&nbsp;&nbsp;";
     }
	return str;
}

//Format a comma separated list of ids to a html-safe string with fixed fieldsizes
function formatIdRow(commaList) {
	var str = "";
	var tmp=commaList.split(',');
    for(i=0;i<tmp.length;i++) {
    	tmp[i] = tmp[i].trim();
        data="&lt"+tmp[i]+"&gt";
        var len = fieldSize+4-data.length;
        while(len>0) {
            data = data+"&nbsp;";
            len--;
        }
        str=str+data+"&nbsp;&nbsp;&nbsp;";
    }
	return str;
}

//Format a list of ids to a html-safe string in compact format
function formatIdRowCompact(commaList) {
	var str = "";
	var tmp=commaList.split(',');
    for(i=0;i<tmp.length;i++) {
    	tmp[i] = tmp[i].trim();
        data="&lt"+tmp[i]+"&gt";
        str=str+data+"&nbsp;";
    }
	return str;
}

function buildDfcData(dfc, idx) {

	if (dfcHeadings.length == 0) {
		dfcVal[0]=[];
		dfcVal[1]=[];
		dfcVal[2]=[];
		dfcVal[3]=[];
		dfcVal[4]=[];
		if (dfc.indexOf("no response") > -1) {
			return;
		} else {
			dfc=dfc.replace(/\n/g, " ");
			dfc=dfc.replace(/\r/g, " ");
			var tmp=dfc.split(' ');
			var ctr=0
			for(i=0;i<tmp.length;i++) {
				tmp[i]=tmp[i].trim();
				if (tmp[i].length>0) {
					if (ctr%2==0) {
						dfcHeadings[ctr/2]=tmp[i];
					}
					ctr=ctr+1;
				}
			}
		}
	}
	if (dfcHeadings.length > 0) {
		if (dfc.indexOf("no response") > -1) {
			dfcVal[idx]=[];
			return;
		} else {
			dfc=dfc.replace(/\n/g, " ");
			dfc=dfc.replace(/\r/g, " ");
			var tmp=dfc.split(' ');
			var ctr=0
			for(i=0;i<tmp.length;i++) {
				tmp[i]=tmp[i].trim();
				if (tmp[i].length>0) {
					if (ctr%2==1) {
						dfcVal[idx][Math.trunc(ctr/2)]=""+tmp[i];
					}
					ctr=ctr+1;
				}
			}
		}
	}
}

function padding(val, fieldSize, pad) {
	s=""+val;
	for(i=s.length;i<fieldSize;i++) {
		s=s+pad
	}
	return s;
}

//Status variables, for parameters values fetched from other simulators
var mr1="", mr2="", mr3="", mr4="", mr5="", mr6="", mr7="", mr8="", mr9="", mr10="", mr11="", mr12="", mr13="";

var dr1="", dr2="", dr3="", dr4="", dr5="", dr6="", dr7="", dr8="", dr9="", dr10="", dr11="", dr12="", dr13="";

var drr1="", drr2="", drr3="", drr4="", drr5="", drr6="", drr7="", drr8="", drr9="";

//Heartbeat var
var dfc0,dfc1,dfc2,dfc3,dfc4;

app.get("/mon",function(req, res){

	//DFC
	getSimCtr("http://127.0.0.1:8100/status", function(data) {
		dfc0 = data;
		buildDfcData(dfc0, 0);
    });
	getSimCtr("http://127.0.0.1:8101/status", function(data) {
		dfc1 = data;
		buildDfcData(dfc1, 1);
    });
	getSimCtr("http://127.0.0.1:8102/status", function(data) {
		dfc2 = data;
		buildDfcData(dfc2, 2);
    });
	getSimCtr("http://127.0.0.1:8103/status", function(data) {
		dfc3 = data;
		buildDfcData(dfc3, 3);
    });
	getSimCtr("http://127.0.0.1:8104/status", function(data) {
		dfc4 = data;
		buildDfcData(dfc4, 4);
    });

	//MR
    getSimCtr("http://127.0.0.1:2222/groups/ctr_requests", function(data) {
    	mr1 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups/ctr_responses", function(data) {
    	mr2 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups/ctr_unique_files", function(data) {
    	mr3 = data;
    });
    getSimCtr("http://127.0.0.1:2222/tc_info", function(data) {
    	mr4 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups/ctr_events", function(data) {
    	mr5 = data;
    });
    getSimCtr("http://127.0.0.1:2222/execution_time", function(data) {
    	mr6 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups/ctr_unique_PNFs", function(data) {
    	mr7 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups/exe_time_first_poll", function(data) {
    	mr8 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups/ctr_files", function(data) {
    	mr9 = data;
    });
    getSimCtr("http://127.0.0.1:2222/status", function(data) {
    	mr10 = data;
    });
    getSimCtr("http://127.0.0.1:2222/groups", function(data) {
    	mr11 = data;
    });
    getSimCtr("http://127.0.0.1:2222/changeids", function(data) {
    	mr12 = data;
    });
    getSimCtr("http://127.0.0.1:2222/fileprefixes", function(data) {
    	mr13 = data;
    });

    //DR
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_query", function(data) {
    	dr1 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_query_published", function(data) {
    	dr2 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_query_not_published", function(data) {
    	dr3 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_req", function(data) {
    	dr4 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_req_redirect", function(data) {
    	dr5 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_req_published", function(data) {
    	dr6 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_published_files", function(data) {
    	dr7 = data;
    });
    getSimCtr("http://127.0.0.1:3906/tc_info", function(data) {
    	dr8 = data;
    });
    getSimCtr("http://127.0.0.1:3906/execution_time", function(data) {
    	dr9 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_double_publish", function(data) {
    	dr10 = data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds", function(data) {
    	dr11=data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_query_bad_file_prefix", function(data) {
    	dr12=data;
    });
    getSimCtr("http://127.0.0.1:3906/feeds/ctr_publish_req_bad_file_prefix",function(data) {
    	dr13=data;
    });

    //DR REDIR
    getSimCtr("http://127.0.0.1:3908/feeds/ctr_publish_requests", function(data) {
    	drr1 = data;
    });
    getSimCtr("http://127.0.0.1:3908/feeds/ctr_publish_responses", function(data) {
    	drr2 = data;
    });
    getSimCtr("http://127.0.0.1:3908/tc_info", function(data) {
    	drr3 = data;
    });
    getSimCtr("http://127.0.0.1:3908/execution_time", function(data) {
    	drr4 = data;
    });
    getSimCtr("http://127.0.0.1:3908/feeds/time_lastpublish", function(data) {
    	drr5 = data;
    });
    getSimCtr("http://127.0.0.1:3908/feeds/dwl_volume", function(data) {
    	drr6 = data;
    });
    getSimCtr("http://127.0.0.1:3908/feeds", function(data) {
    	drr7=data;
    });
    getSimCtr("http://127.0.0.1:3908/feeds/ctr_publish_requests_bad_file_prefix", function(data) {
    	drr8 = data;
    });
    getSimCtr("http://127.0.0.1:3908/speed", function(data) {
    	drr9 = data;
    });

  //Build web page
	var str = "<!DOCTYPE html>" +
          "<html>" +
          "<head>" +
            "<meta http-equiv=\"refresh\" content=\"5\">"+  //5 sec auto refresh
            "<title>DFC and simulator monitor</title>"+
            "</head>" +
            "<body>" +
            "<h3>DFC apps</h3>" +
            "<font face=\"monospace\">";
//            "dfc_app0: " + dfc0 + "<br>" +
//            "dfc_app1: " + dfc1 + "<br>" +
//            "dfc_app2: " + dfc2 + "<br>" +
//            "dfc_app3: " + dfc3 + "<br>" +
//            "dfc_app4: " + dfc4 + "<br>";

	for(id=0;id<5;id++) {
		if (id==0) {
			str=str+padding("Instance",22,".");
			str=str+"&nbsp;"+"&nbsp;";
		}
		str=str+padding("dfc_app"+id,26, "&nbsp;");
		str=str+"&nbsp;"+"&nbsp;";
	}
	str=str+"<br>";

	if (dfcHeadings.length > 0) {
		var hl=0;
		for(hl=0;hl<dfcHeadings.length;hl++) {
			str=str+padding(dfcHeadings[hl], 22, ".");
			for(id=0;id<5;id++) {
				if (dfcVal[id].length > 0) {
					val=""+padding(dfcVal[id][hl], 26, "&nbsp;");
				} else {
					val=""+padding("-", 26, "&nbsp;");
				}
				str=str+"&nbsp;"+"&nbsp;"+val;
			}
			str=str+"<br>";
		}
	}

            str=str+"</font>"+
            "<h3>MR Simulator</h3>" +
            "<font face=\"monospace\">"+
            "MR TC:........................................." + mr4 + "<br>" +
            "Configured filename prefixes:.................." + formatIdRowCompact(mr13) + "<br>" +
            "Status:........................................" + mr10 + "<br>" +
            "Execution time (mm.ss):........................" + mr6 + "<br>" +
            "Configured groups:............................." + formatIdRow(mr11) + "<br>" +
            "Configured change identifiers:................." + formatIdRow(mr12) + "<br>" +
            "Execution time from first poll (mm.ss):....... " + formatDataRow(mr8) + "<br>" +
            "Number of requests (polls):...................." + formatDataRow(mr1) + "<br>" +
            "Number of responses (polls):..................." + formatDataRow(mr2) + "<br>" +
            "Number of files in all responses:.............." + formatDataRow(mr9) + "<br>" +
            "Number of unique files in all responses:......." + formatDataRow(mr3) + "<br>" +
            "Number of events..............................." + formatDataRow(mr5) + "<br>" +
            "Number of unique PNFs.........................." + formatDataRow(mr7) + "<br>" +
            "</font>"+
            "<h3>DR Simulator</h3>" +
            "<font face=\"monospace\">"+
            "DR TC:........................................." + dr8 + "<br>" +
            "Execution time (mm.ss):........................" + dr9 + "<br>" +
            "Configured feeds (feedId:filePrefix)..........." + formatIdRow(dr11) +"<br>" +
            "Number of queries:............................." + formatDataRow(dr1) + "<br>" +
            "Number of queries with bad file name prefix:..." + formatDataRow(dr12) + "<br>" +
            "Number of query responses, file published:....." + formatDataRow(dr2) + "<br>" +
            "Number of query responses, file not published:." + formatDataRow(dr3) + "<br>" +
            "Number of requests:............................" + formatDataRow(dr4) + "<br>" +
            "Number of requests with bad file name prefix:.." + formatDataRow(dr13) + "<br>" +
            "Number of responses with redirect:............." + formatDataRow(dr5) + "<br>" +
            "Number of responses without redirect:.........." + formatDataRow(dr6) + "<br>" +
            "Number of published files:....................." + formatDataRow(dr7) + "<br>" +
            "Number of double published files:.............." + formatDataRow(dr10) + "<br>" +
            "</font>"+
            "<h3>DR Redirect Simulator</h3>" +
            "<font face=\"monospace\">" +
            "DR REDIR TC:..................................." + drr3 + "<br>" +
            "Execution time (mm.ss):........................" + drr4 + "<br>" +
            "Publish speed (files/sec):....................." + drr9 + "<br>" +
            "Configured feeds (feedId:filePrefix)..........." + formatIdRow(drr7) +"<br>" +
            "Number of requests:............................" + formatDataRow(drr1) + "<br>" +
            "Number of requests with bad file name prefix:.." + formatDataRow(drr8) + "<br>" +
            "Number of responses:..........................." + formatDataRow(drr2) + "<br>" +
            "Downloaded volume (bytes):....................." + formatDataRow(drr6) + "<br>" +
            "Last publish (mm:ss):.........................." + formatDataRow(drr5) + "<br>" +
            "</font>"+
           "</body>" +
          "</html>";
	res.send(str);

})

var httpServer = http.createServer(app);
var httpPort=9999;
httpServer.listen(httpPort);
console.log("Simulator monitor listening (http) at "+httpPort);
console.log("Open the web page on localhost:9999/mon to view the statistics page.")