var express = require('express');
var app = express();
var redis = require("redis");
var util = require('util');
var os = require("os");

var hostname = os.hostname();
client = redis.createClient({host: "back"});
app.set('trust_proxy', 1);
app.get('/', function(req, res){
	res.send('Requester ip address: '+util.inspect(req.client.remoteAddress)+'<br />NodeJS App Server : '+hostname+'<br />Database id is : '+util.inspect(client.server_info. run_id));
});

app.listen(8000);
