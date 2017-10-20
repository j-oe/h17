/*jshint node:true, esversion:6*/
/** 
	fastclass
	NODE MODULE
	(c) 2017 Jan Oevermann
	jan.oevermann@hs-karlsruhe.de
	License: MIT
*/

var requirejs = require('requirejs');

requirejs.config({
	baseUrl: __dirname,
	paths: {
		'fastclass': 'core/main',
		'modules':   'core/modules',
		'configs':   'core/configs'
	},
	nodeRequire: require
});

var args = process.argv.slice(2);

var publication = args[0],
	stepIn =      args[1],
	stepOut =     args[2],
	sourceFile =  args[3],
	inputMeta =   args[4],
	baseDir =     args[5],
	tmpDir =      args[6],
	pubDir =      args[7],
	component =   args[8];

requirejs(['fs', 'jszip', 'fastclass'], 
	(fs, JSZip, fc) => {

	var inputText = JSON.parse(fs.readFileSync(stepIn, {'encoding': 'utf-8'})),
    	modelPath = inputMeta,
    	modelName = 'Generic';

    var sourceFileContent = fs.readFileSync('publications/' + publication + '/content/' + sourceFile, {'encoding': 'utf-8'}),
		outputFilePath = tmpDir + '/classification.csv',
	    outputFileContent = '';

	fs.readFile(modelPath, (err, data) => {
		JSZip.loadAsync(data).then((zip) => {
			loadModel(zip);
		});
	});

	function classifyMultiple (text, model) {
		text.forEach((unit) => {
			var result = fc.classify(unit.txt, model.data.matrix);
			outputFileContent += unit.xid + ';' + result.pred + ';' + modelName + ';' + result.conf + '\n';
		});

		writeResult();
	}

	function loadModel (zip, type) {
		if (zip.files.hasOwnProperty('fastclass/model.json')) {
			zip.folder('fastclass')
				.file('model.json')
				.async('string')
				.then((data) => {
					var model = JSON.parse(data);
					modelName = model.meta.modelName;

					// hotfix
					if (modelName.indexOf(':')) modelName = modelName.split(':')[1];

					classifyMultiple(inputText, model);
				});
		} else {
			console.log('invalid fcm model');
		}
	}

	function writeResult () {
		fs.appendFileSync(outputFilePath, outputFileContent);
		fs.writeFileSync(stepOut, sourceFileContent);
	}
});