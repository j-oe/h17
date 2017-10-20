/*jshint node:true, esversion:6*/
/** 
	fastclass
	NODE MODULE
	(c) 2017 Jan Oevermann
	jan.oevermann@hs-karlsruhe.de
	License: MIT
*/

console.log('\n-----------------\n fastclass API \n Showcase tekom H17 \n-----------------\n');

var requirejs = require('requirejs');

requirejs.config({
	baseUrl: '.',
	paths: {
		'modules':  'core/modules',
		'configs':  'core/configs'
	},
	nodeRequire: require
});

requirejs([	'express', 'morgan', 'body-parser', 'cors', 'fs', 'jszip', 'core/main'], 
			(express, morgan, bodyParser, cors, fs, JSZip, fc) => {

	/* Configuration */
	var port = process.env.PORT || 8080;

	var models = [{
			name: 'component',
			file: 'data/fastclass_iirdsComponent.fcm'
		},{
			name: 'topictype',
			file: 'data/fastclass_iirdsTopicType.fcm'
		},{
			name: 'informationsubject',
			file: 'data/fastclass_iirdsInformationSubject.fcm'
		},{
			name: 'productlifecyclephase',
			file: 'data/fastclass_iirdsProductLifeCyclePhase.fcm'
		}];

	var Model = {},
		api = express();

	models.forEach((m) => {
		fs.readFile(m.file, (err, data) => {
			JSZip.loadAsync(data).then((zip) => {
				loadModel(zip, m.name);
			});
		});
	});

	api.use(cors())
	   .use(bodyParser.json({ limit: 52428800 }))
	   .use(morgan('dev'));

	api.use((req, res, next) => {
	  res.header("X-powered-by", "fastclass");
	  next();
	});

	api.get('/status', (req, res) => {
		res.json({status: "fastclass API is ready"});
	});

	api.post('/classify', (req, res) => {
		var result = [];		

		req.body.forEach((unit) => {
			unit.clf = [];
			unit._iirds = {};

			models.forEach((m) => {
				var uRes = fc.classify(unit.txt, Model[m.name].data.matrix);
				unit.clf.push(uRes.pred);
				unit._iirds[Model[m.name].meta.modelName] = uRes;
			});

			result.push(unit);
		});

		res.json(result);
	});

	api.post('/classify/:name', (req, res) => {
		var result = [];

		req.body.forEach((unit) => {
			var uRes = fc.classify(unit.txt, Model[req.params.name].data.matrix);

			unit.clf = uRes.pred;
			unit.cfd = uRes.conf;

			result.push(unit);
		});

		res.json(result);
	});

	api.use((req, res, next) => {
		res.status(404).send('Not found (404). Try POST on /classify.');
	});

	api.listen(port, () => {
		console.log('\n=> API listening on port %d', port);
	});						

	function loadModel (zip, type) {
		if (zip.files.hasOwnProperty('fastclass/model.json')) {
			zip.folder('fastclass')
				.file('model.json')
				.async('string')
				.then((data) => {
					Model[type] = JSON.parse(data);
				});
		} 
	}
});