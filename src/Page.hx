import react.ReactComponent;
import react.ReactMacro.jsx;
import zero.react.RouteLink;
import zero.react.BasePageProps;

typedef PageData = {
	footer:String
}
typedef PageProps = {>BasePageProps, >PageData,}

class Page extends ReactComponentOfProps<PageProps> {

	static var STYLES = Webpack.require('./styles/styles.pcss');

	static public function getInitialData(route:ZeroRoute):PageData {
		// object or js.Promise
		return {
			footer: 'The power of Webpack and the speed of Haxe, without the hassle!'
		}
	}

	override function render() {
		// can be a more complex React app root, like Redux provider, ReactIntl...
		return jsx('
			<section className="page">
				<Nav/>
				${props.children}
				<footer>${props.footer}</footer>
			</section>
		');
	}
}

class Nav extends ReactComponent {
	override function render() {
		return jsx('
			<nav>
				<RouteLink activeClassName="active" href="/">
					Home
				</RouteLink>
				<RouteLink activeClassName="active" href="/about">
					About
				</RouteLink>
			</nav>
		');
	}
}
