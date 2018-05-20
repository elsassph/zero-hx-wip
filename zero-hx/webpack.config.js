const fs = require("fs");
const path = require("path");
const webpack = require("webpack");

const postcssConfig = `${__dirname}/postcss.config.js`;

module.exports = {
	mode: "development",
	devtool: "eval-source-map",
	entry: {
		main: "./build.hxml"
	},
	output: {
		publicPath: "/",
		filename: "[name].js"
	},
	module: {
		rules: [
			{
				test: /\.hxml$/,
				loader: "haxe-loader",
				options: {
					debug: true
				}
			},
			{
				test: /\.(gif|png|jpg|svg)$/,
				loader: "url-loader",
				options: {
					name: "[name].[ext]",
					limit: 8192
				}
			},
			{
				test: /\.(p)?css$/,
				use: [
					"style-loader",
					{
						loader: "css-loader",
						options: {
							importLoaders: 1
						}
					},
					{
						loader: "postcss-loader",
						options: {
							config: {
								path: postcssConfig
							}
						}
					}
				]
			}
		]
	}
};
