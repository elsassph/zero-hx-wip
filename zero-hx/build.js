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
const packageJson = path.resolve(rootFolder, "package.json");
const config = JSON.parse(fs.readFileSync(packageJson)).config;
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
	const manifest = stats.compilation.chunks.find(
		chunk => chunk.name === "manifest"
	);
	const main = stats.compilation.chunks.find(chunk => chunk.name === "main");
	if (!main) {
		console.log("Webpack build failed silently");
		process.exit(1);
		return;
	}
	const mainAssets = manifest
		? manifest.files.concat(main.files)
		: main.files;
	const publicPath = clientConfig.output.publicPath;
	const html = renderHtml(config, publicPath, mainAssets);
	fs.writeFileSync(path.join(clientConfig.output.path, "index.html"), html);

	fs.copyFileSync(
		path.join(__dirname, "server.js"),
		path.join(distFolder, "server.js")
	);
	console.log("SUCCESS");
});
