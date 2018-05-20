const fs = require("fs");
const path = require("path");
const express = require("express");

const PORT = process.env.PORT || 5000;

// prepare
const publicFolder = path.resolve(__dirname, "./public");
const shell = fs.readFileSync(path.join(publicFolder, "index.html"));

// setup server
const server = express();
server.use(express.static(publicFolder, { index: false }));

server.use((req, res) => {
	if (req.url.startsWith("/favicon")) {
		res.status(404);
		res.end();
		return;
	}

	const html = shell;
	res.header("Content-Type", "text/html");
	res.send(html);
});
server.listen(PORT, () => console.log(`Listening on ${PORT}`));
