import js.Browser.document;
import react.ReactComponent;
import react.ReactDOM;
import react.ReactMacro.jsx;
import react.ReactPropTypes;

class ZeroReactRouter extends ZeroRouter {

	static function main() {
		var router = new ZeroReactRouter();
		router.start();
	}

	var root:ZeroRoot;
	var pageData:Dynamic;

	override function initialRoute() {
		var app = ReactDOM.render(
			jsx('<ZeroRoot ref={setRoot} history={history}/>'),
			document.getElementById('root'));

		#if debug
		ReactHMR.autoRefresh(app);
		var hot:ReactHMR.ModuleHMR = untyped module.hot;
		if (hot != null) {
			hot.status(function(status) {
				if (status == 'ready') {
					// error overlay tends to stick
					var overlay = document.getElementById('webpack-hot-middleware-clientOverlay');
					if (overlay != null) overlay.remove();
				}
			});
		}
		#end

		super.initialRoute();
	}

	function setRoot(root:ZeroRoot) {
		this.root = root;
	}

	override function resolveRoute(route:ZeroRoute) {
		root.setState({ loadingRoute: route });
		if (pageData == null) {
			pageData = {};
			var getInitialData:ZeroRoute->Dynamic = untyped Page.getInitialData;
			if (getInitialData != null) {
				var data:Dynamic = getInitialData(route);
				if (data == null || data.then == null) data = js.Promise.resolve(data);
				data.then(function(data) {
					if (data != null) pageData = data;
					resolveRoute(route);
				});
				return;
			}
		}
		super.resolveRoute(route);
	}

	override function activateRoute(route:ZeroRoute, routeClass:Class<Dynamic>, routeData:Dynamic) {
		root.setState({
			loadingRoute: null,
			route: route,
			routeClass: routeClass,
			routeData: routeData,
			pageData: pageData
		});
	}
}

class ZeroRoot extends ReactComponent {

	static public var childContextTypes = { history: ReactPropTypes.object.isRequired };

	public function getChildContext() {
		return {
			history: props.history
		};
	}

	public function new(props) {
		super(props);
		state = {};
	}

	override public function render() {
		return jsx('
			<Page route={state.route} isLoading={state.loadingRoute} {...state.pageData}>
				{renderRoute()}
			</Page>
		');
	}

	function renderRoute() {
		if (state.routeClass != null)
			return jsx('<state.routeClass route={state.route} {...state.routeData}/>');
		else
			return null;
	}
}
