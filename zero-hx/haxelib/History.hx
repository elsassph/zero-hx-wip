import haxe.extern.EitherType;
import js.html.Location;

@:enum
abstract HistoryAction(String) {
	var Push = 'PUSH';
	var Replace = 'REPLACE';
	var Pop = 'POP';
}

typedef BrowserHistoryOptions = {
	/** The base URL of the app */
	?basename: String,
	/** Set true to force full page refreshes */
	?forceRefresh: Bool,
	/** The length of location.key */
	?keyLength: Int,
	/** A function to use to confirm navigation with the user */
	?getUserConfirmation: Dynamic
}

@:jsRequire('history', 'createBrowserHistory')
extern class BrowserHistory extends History {
	@:selfCall
	public function new(?options: BrowserHistoryOptions);
}

typedef LocationTarget = EitherType<
	String,
	{ pathname: String, ?search: String, ?hash: String, ?state: Dynamic }
>;

extern class HistoryLocation extends Location {
	public var state: Dynamic;
	public var key: String;
}

extern class History {
	public var length: Int;
	public var location: HistoryLocation;
	public var action: HistoryAction;

	public function go(n: String): Void;
	public function goBack(): Void;
	public function goForward(): Void;
	public function push(location: LocationTarget): Void;
	public function replace(location: LocationTarget): Void;

	public function block(guard: Dynamic): Void -> Void;
	public function listen(callback: HistoryLocation -> HistoryAction -> Void): Void -> Void;
}
