package route;

import react.ReactComponent;
import react.ReactMacro.jsx;

class Index extends ReactComponent {

	override function render() {
		return jsx('
			<section className="content">
				<h1>Create Haxe React Apps</h1>
				<p>Zero configuration webapps with Haxe:</p>
				<ul>
					<li>React app with built-in page routing, splitting and hot-reloading</li>
					<li>Webpack goodness for assets processing</li>
					<li>Built-in pattern for loading page data</li>
				</ul>
			</section>
		');
	}
}
