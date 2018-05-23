const fs = require("fs");
const path = require("path");
const webpack = require("webpack");
const webpackDevMiddleware = require("webpack-dev-middleware");
const webpackHotMiddleware = require("webpack-hot-middleware");
const express = require("express");
const renderHtml = require("./html");

const PORT = process.env.PORT || 3000;

function normalizeArray(a) {
	return Array.isArray(a) ? a : [a];
}

// prepare
const rootFolder = process.cwd();
const packageJson = path.resolve(rootFolder, "package.json");

const config = JSON.parse(fs.readFileSync(packageJson)).config;
const clientConfig = require("./webpack.config.js");
const publicFolder = path.resolve(rootFolder, "public");
const outputFolder = path.resolve(rootFolder, "dist/public");

clientConfig.output.path = outputFolder;
clientConfig.entry.main = ["webpack-hot-middleware/client"].concat(
	normalizeArray(clientConfig.entry.main)
);

// https://webpack.js.org/configuration/node/
clientConfig.node = {
	fs: "empty",
	net: "empty",
	tls: "empty"
};

clientConfig.plugins = [
	new webpack.HotModuleReplacementPlugin(),
	new webpack.NamedModulesPlugin()
];

const clientCompiler = webpack(clientConfig);

// setup server
const server = express();
server.use(express.static(publicFolder));

// https://github.com/webpack/webpack-dev-middleware
server.use(
	webpackDevMiddleware(clientCompiler, {
		serverSideRender: true
	})
);
// https://github.com/glenjamin/webpack-hot-middleware
server.use(webpackHotMiddleware(clientCompiler)); //, { log: false }));

server.use((req, res) => {
	if (req.url.startsWith("/favicon")) {
		res.status(404);
		res.end();
		return;
	}

	const stats = res.locals.webpackStats.toJson();
	const mainAssets = normalizeArray(stats.assetsByChunkName.main);
	const publicPath = stats.publicPath;
	const html = renderHtml(config, publicPath, mainAssets);
	res.send(html);
});
server.listen(PORT, () => console.log(`Listening on ${PORT}`));
