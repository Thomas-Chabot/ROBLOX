var child_process = require('child_process');
var fs = require('fs');

//Create the api file.
function createApiFile(cb){
	child_process.exec('GetAPI.bat', function(error, stdout, stderr) {
		cb();
	});
};

//Convert the text data to json format.
function convertData(cb){
	var classData = {};
	var lastClass = undefined;
	var deprecated = false;
	fs.readFile('api.txt', 'utf8', function(error, data) {
		if (error) {
			throw error;
		}
		var linesSplit = data.split('\n'); //Split text data by new line.
		//Loop through every line and check if it's a Class name or a property. Add to classData object appropriately.
		for (var i = 0; i < linesSplit.length; i++) {
			var line = linesSplit[i];
			if (line.indexOf('\t') == -1) {
				if (line.indexOf('[deprecated]') == -1 && line.indexOf('[notCreatable]') == -1){
					deprecated = false
					var BaseClassNameStr = undefined;
					if (line.indexOf('[') !== -1) {
						line = line.replace(/ ([[]).+/,'');
					};
					if (line.indexOf(':') !== -1) {
						BaseClassNameStr = line.split(':')[1].replace(' ','').replace('\r','')
						line = line.replace(/ ([:]).+/,'');
					}
					classData[line.replace('\t','').replace('\r','').replace('Class ','')] = {properties:{},BaseClassName:BaseClassNameStr};
					lastClass = line.replace('\t','').replace('\r','').replace('Class ','');
				} else {
					deprecated = true
				};
			} else {
				if (deprecated == false && line.indexOf('Function') == -1 && line.indexOf('Event') == -1 && line.indexOf('[deprecated]') == -1 && line.indexOf('[readonly]') == -1 && line.indexOf('[PluginSecurity]') == -1 && line.indexOf('[RobloxPlaceSecurity]') == -1 && line.indexOf('[hidden]') == -1) {
					line = line.replace('\t','').replace('\r','').replace('Property ','');
					var propertySplit = line.split(' ')
					var propertyData = {}
					propertyData['class'] = propertySplit[0]
					classData[lastClass].properties[propertySplit[1].split('.')[1]] = propertyData
				};
			};
		};
		cb(JSON.stringify(classData));
	});
};

createApiFile(function(){
	convertData(function(json){
		fs.writeFile('APIParsed.txt',json, function(err) {
			if (err) {
				throw err;
			};
		});
	});
});