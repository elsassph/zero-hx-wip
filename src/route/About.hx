package route;

import react.ReactComponent;
import react.ReactMacro.jsx;
import zero.react.RouteProps;

typedef AboutData = {
	npmLibs:Array<String>,
	haxeLibs:Array<String>
}

typedef AboutProps = {>RouteProps, >AboutData,}

class About extends ReactComponentOfProps<AboutProps> {

	static var STYLES = Webpack.require('../styles/about.css');

	static public function getInitialData(route:ZeroRoute):AboutData {
		// object or js.Promise
		return Webpack.require('../about-libs.json');
	}

	override function render() {
		return jsx('
			<section className="content about">
				<h1>Npm libraries:</h1>
				<ul>
					${renderEntries(props.npmLibs)}
				</ul>
				<h1>Haxelib libraries:</h1>
				<ul>
					${renderEntries(props.haxeLibs)}
				</ul>
			</section>
		');
	}

	function renderEntries(list:Array<String>) {
		if (list == null) return [];
		var i = 0;
		return list.map(function(it) return jsx('<li key={i++}>{it}</li>'));
		// note: normally it's bad to use an array index as key! it should be an item ID
	}

}
