import History;
import haxe.DynamicAccess;
import js.Promise;

@:build(ZeroMacro.build())
class ZeroRouter {

	static var routes:DynamicAccess<Void->js.Promise<Dynamic>>; // macro populated from filesystem

	var history:History;
	var preflightRoute:{ route:String, routeClass:Class<Dynamic> };
	var currentRoute:ZeroRoute;

	static function main() {
		var router = new ZeroRouter();
		router.start();
	}

	function new() {
	}

	function start() {
		history = new BrowserHistory();
		history.listen(routeChanged);
		initialRoute();
	}

	function initialRoute() {
		routeChanged(history.location, history.action);
	}

	function routeChanged(location:HistoryLocation, action:HistoryAction) {
		if (action != HistoryAction.Replace
			&& currentRoute != null
			&& currentRoute.location.pathname == location.pathname)
			return;

		var route:ZeroRoute = cast getRoute(location.pathname);
		route.location = location;
		route.action = action;
		route.history = history;
		resolveRoute(route);
	}

	function getRoute(pathname:String):{ name:String, args:Array<String> } {
		if (pathname == '/') return { name: 'index', args: [] };

		var parts = pathname.substr(1).split('/');
		return {
			name: parts.shift(),
			args: parts
		};
	}

	function resolveRoute(route:ZeroRoute) {
		currentRoute = route;

		var routeName = route.name;
		if (!routes.exists(routeName)) routeName = 'error';

		if (preflightRoute != null && preflightRoute.route == routeName) {
			routeResolved(route, preflightRoute.routeClass);
			preflightRoute = null;
			return;
		}

		var loader = routes.get(routeName);
		loader().then( routeResolved.bind(route) );
	}

	function routeResolved(route:ZeroRoute, routeClass:Class<Dynamic>) {
		if (route != currentRoute) return;

		var getInitialData:ZeroRoute->Dynamic = untyped routeClass.getInitialData;
		if (getInitialData != null) {
			var data:Dynamic = getInitialData(route);
			if (data == null || data.then == null) data = Promise.resolve(data);
			data.then(function(data) {
				applyRoute(route, routeClass, data);
			});
			return;
		}

		applyRoute(route, routeClass, null);
	}

	function applyRoute(route:ZeroRoute, routeClass:Class<Dynamic>, routeData:Dynamic) {
		if (route != currentRoute) return;
		currentRoute = route;

		activateRoute(route, routeClass, routeData);
	}

	function activateRoute(route:ZeroRoute, routeClass:Class<Dynamic>, routeData:Dynamic) {
		// abstract
	}
}
