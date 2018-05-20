package zero.react;

import react.ReactComponent;
import react.ReactEvent;
import react.ReactMacro.jsx;
import react.ReactPropTypes;

typedef LinkProps = {
	?id:String,
	href:String,
	?title:String,
	?className:String,
	?tabIndex:String,
	?onClick:ReactEvent->Void,
	?onFocus:ReactEvent->Void,
	?onBlur:ReactEvent->Void
}

class Link extends ReactComponentOfProps<LinkProps> {

	static public var contextTypes = { history: ReactPropTypes.object.isRequired };

	var history:History;

	public function new(props:LinkProps, context) {
		history = context.history;
		super(props);
	}

	override public function render() {
		return jsx('<a {...props} onClick={onClick}/>');
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
