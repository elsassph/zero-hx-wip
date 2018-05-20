#if macro
import sys.FileSystem;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

class ZeroMacro {

	static public function build():Array<Field> {
		var cwd = Sys.getCwd();
		var cp = Path.join([cwd, 'src', 'route']);
		var files = FileSystem.readDirectory(cp)
			.filter(function(file) return Path.extension(file) == 'hx')
			.map(function(file) return Path.withoutExtension(file));

		var routes = files.map(function(name) {
			var forceIncludeClass = Context.getType('route.' + name);
			var module = 'route_' + name;
			var loader = Webpack.createLoader(module);
			return {
				field: name.toLowerCase(),
				expr: macro function() {
					return ${loader}.then( function(_) {
						return untyped $i{module};
					});
				}
			}
		}).filter(function(field) return field != null);

		var decl = { expr: EObjectDecl(routes), pos: Context.currentPos() };

		var fields = Context.getBuildFields();
		for (field in fields) {
			if (field.name == 'routes') {
				switch (field.kind) {
					case FieldType.FVar(t, _): field.kind = FieldType.FVar(t, decl);
					default: throw 'ZeroRouter.routes should be a variable';
				}
				break;
			}
		}
		return fields;
	}

}
#end
