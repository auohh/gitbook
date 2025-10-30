var cheerio = require('cheerio');
var fs = require('fs');
var url = require('url');
var path = require('path');

var urls = [];

module.exports = {
	hooks: {

		"page": function (page) {
			var config = this.config;

			var output = this.output;

			if (output.name != 'website') return page;

			var lang = '';
			if (this.isLanguageBook()) {
				lang = config.values.language;
			}
			if (lang){
				lang = lang + '/';
			}

			var pluginConfig = this.options.pluginsConfig || {};
			var customHTML = pluginConfig.customHTML || {};

			var toURL = (customHTML.toURL || '_book') + '/';
			toURL= toURL + lang + page.path;
			
			var url = output.toURL(toURL);

			var isHtml = (url.substr(-5, 5) == '.html');
			if (!isHtml) {
				url += 'index.html';
			}
			urls.push({
				url: url
			});
			return page;

		},

		"finish" : function () {
			var modifyPage;
			var $, $el, html;

			var pluginConfig = this.options.pluginsConfig || {};
			var customHTML = pluginConfig.customHTML || {};
			var jsPath = customHTML.js || '';
			var fullPath = path.join(process.cwd(), jsPath);
			if (fs.existsSync(jsPath)) {
				modifyPage = require(fullPath);
			}
			else {
				modifyPage = function ($) {
					return $.html();
				}
			}

			urls.forEach(item => {
				html = fs.readFileSync(item.url, {encoding: 'utf-8'});
				$ = cheerio.load(html);
				var newPage = modifyPage($);
				fs.writeFileSync(item.url, newPage);
			});
		}

	},
	blocks: {},
	filters: {}
};
