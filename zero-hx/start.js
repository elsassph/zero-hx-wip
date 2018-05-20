const fs = require("fs");
const path = require("path");
const exec = require("child_process").exec;

const rootFolder = process.cwd();
const server = path.join(rootFolder, "dist/server.js");

if (fs.existsSync(server)) {
	require(server);
} else {
	console.log("Compiling project for release...");
	exec(`npm run release`, (err, stdout, stderr) => {
		console.log(stderr);
		console.log(stdout);
		if (err) {
			console.log(err);
			process.exist(1);
		}
		require(server);
	});
}
