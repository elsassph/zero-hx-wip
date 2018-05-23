const t0 = new Date().getTime();

const fs = require("fs");
const path = require("path");
const webpack = require("webpack");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const renderHtml = require("./html");

// prepare
const rootFolder = process.cwd();
const packageJsonPath = path.resolve(rootFolder, "package.json");
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath).toString());
const config = packageJson.config;
const isProd = process.argv.includes("--release");
const isHashed = !!config.hash;
const distFolder = path.resolve(rootFolder, "dist");

// - client
const clientConfig = require("./webpack.config.js");
const publicFolder = path.resolve(rootFolder, "public");
const clientOutputFolder = path.resolve(distFolder, "public");

clientConfig.output.path = clientOutputFolder;
clientConfig.plugins = [
	new MiniCssExtractPlugin({
		filename: isHashed ? `[name].${config.hash}.css` : "[name].css"
	}),
	new CopyWebpackPlugin(
		[
			{
				from: publicFolder,
				to: clientOutputFolder
			}
		],
		{
			copyUnmodified: true
		}
	)
];
clientConfig.module.rules.forEach(rule => {
	if (rule.use && rule.use[0] === "style-loader") {
		rule.use.splice(0, 1, MiniCssExtractPlugin.loader);
	}
});

if (isProd) {
	clientConfig.mode = "production";
	clientConfig.devtool = false;
	clientConfig.module.rules.forEach(rule => {
		if (rule.loader === "haxe-loader") {
			rule.options.debug = false;
		}
	});
	clientConfig.optimization = {
		minimizer: [
			new UglifyJsPlugin({
				cache: true,
				parallel: true
			}),
			new OptimizeCSSAssetsPlugin({})
		]
	};
} else {
	clientConfig.optimization = {
		minimizer: []
	};
}

if (isHashed) {
	clientConfig.output.filename = clientConfig.output.filename.replace(
		".js",
		`.${config.hash}.js`
	);
	clientConfig.optimization.runtimeChunk = {
		name: "manifest"
	};
}

// - server TODO

/*const serverConfig = {
  mode: clientConfig.mode,
  devtool: clientConfig.devtool,
  entry: {
    './zero-hx/server.js'
  },
  output: {
    path: path.join(publicFolder, '../server'),
    filename: 'index.js'
  }
}*/

// clean
const rimraf = require("rimraf");
rimraf.sync(clientOutputFolder);

// build
const clientCompiler = webpack(clientConfig);

clientCompiler.run((err, stats) => {
	if (err) {
		console.log("FAILED");
		process.exit(1);
		return;
	}

	const info = stats.toJson();
	if (stats.hasErrors()) {
		console.error(info.errors);
	}
	if (stats.hasWarnings()) {
		console.warn(info.warnings);
	}

	const manifest = normalizeArray(info.assetsByChunkName.manifest);
	const main = normalizeArray(info.assetsByChunkName.main);
	if (!main) {
		process.exit(1);
		return;
	}
	const mainAssets = manifest
		? manifest.concat(main)
		: main;
	const publicPath = clientConfig.output.publicPath;
	const html = renderHtml(config, publicPath, mainAssets);
	fs.writeFileSync(path.join(clientConfig.output.path, "index.html"), html);

	setupServer();

	console.log(
		"Completed in",
		((new Date().getTime() - t0) / 1000).toFixed(1) + "s"
	);
});

function setupServer() {
	fs.copyFileSync(
		path.join(__dirname, "server.js"),
		path.join(distFolder, "server.js")
	);
	const serverPkg = {
		name: packageJson.name,
		engines: packageJson.engines,
		version: packageJson.version,
		dependencies: packageJson.dependencies,
		scripts: {
			start: "node server.js"
		}
	};
	fs.writeFileSync(
		path.join(distFolder, "package.json"),
		JSON.stringify(serverPkg, 2)
	);
}

function normalizeArray(a) {
	if (!a) return null;
	return Array.isArray(a) ? a : [a];
}
