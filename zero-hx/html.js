module.exports = function render(config, publicPath, assets) {
	return `<!DOCTYPE html>
<html>
<head>
  <title>${config.title}</title>
  <link rel="shortcut icon" type="image/png" href="${publicPath}favicon.png"/>
  ${assets
		.filter(path => path.endsWith(".css"))
		.map(path => `<link rel="stylesheet" href="${publicPath}${path}" />`)
		.join("")}
</head>
<body>
  <div id="root"></div>
  ${assets
		.filter(path => path.endsWith(".js"))
		.map(path => `<script src="${publicPath}${path}"></script>`)
		.join("")}
</body>
</html>`;
};
