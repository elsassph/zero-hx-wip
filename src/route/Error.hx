package route;

import react.ReactComponent;
import react.ReactMacro.jsx;
import zero.react.RouteProps;

class Error extends ReactComponentOfProps<RouteProps> {

	override function render() {
		return jsx('
			<div>
				<h1>Page not found</h1>
				<p><b>${props.route.location.pathname}</b> does not exist.</p>
			</div>
		');
	}
}
