var express = require('express');
var app = express();
var fs = require('fs');

function get(source) {
	fs.readFile('.' + source, 'utf8', function read(err, data){
		if(err){ throw err; }
		return data
	})
}

app.get('/*', function (req, res) {
	var source = req.path
	res.send(get(source))
})

app.post('/*', function (req, res) {
	var source = req.path
	var result = ''
	req.on('data', function(chunk) {
		result += chunk.toString()
	})
	req.on('end', function() {
		if(get(source)!=result) {
			fs.writeFile('.' + source, result, function(err) {
				if(err) {
					res.send(err)
					return console.log(err)
				}
			})
		}
		res.send('success')
	})
})

app.listen(3000)
