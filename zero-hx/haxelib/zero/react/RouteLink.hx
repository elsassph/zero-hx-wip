package zero.react;

import react.ReactComponent;
import react.ReactEvent;
import react.ReactMacro.jsx;
import react.ReactPropTypes;
import react.ReactUtil;

typedef RouteLinkProps = {> zero.react.Link.LinkProps,
	?activeClassName:String
}
typedef RouteLinkState = {
	className:String
}

class RouteLink extends ReactComponentOfPropsAndState<RouteLinkProps, RouteLinkState> {

	static public var contextTypes = { history: ReactPropTypes.object.isRequired };

	static public function getClassName(pathname:String, props:RouteLinkProps) {
		if (props.activeClassName != null && props.href == pathname) {
			if (props.className != null) return props.className + ' ' + props.activeClassName;
			else return props.activeClassName;
		}
		return props.className;
	}

	var history:History;
	var removeHistoryListener:Void->Void;
	var curPath:String;

	public function new(props:RouteLinkProps, context) {
		super(props);

		history = context.history;
		removeHistoryListener = history.listen(historyChanged);
		curPath = history.location.pathname;

		state = {
			className: getClassName(curPath, props)
		}
	}

	function historyChanged(location:History.HistoryLocation, action:History.HistoryAction) {
		curPath = history.location.pathname;
		if (props.activeClassName != null)
			setState({
				className: getClassName(curPath, props)
			});
	}

	override public function componentWillReceiveProps(nextProps:RouteLinkProps):Void {
		setState({
			className: getClassName(curPath, nextProps)
		});
	}

	override public function componentWillUnmount():Void {
		removeHistoryListener();
	}

	override public function render() {
		var aProps = props.activeClassName != null
			? ReactUtil.copyWithout({}, props, ['activeClassName'])
			: props;
		return jsx('<a {...aProps} onClick={onClick} className={state.className}/>');
	}

	function onClick(e:ReactEvent) {
		if (props.onClick != null) {
			props.onClick(e);
			if (e.isDefaultPrevented()) return;
		}
		if (props.href == null || props.href.indexOf('://') >= 0) return;
		e.preventDefault();
		history.push(props.href);
	}
}
