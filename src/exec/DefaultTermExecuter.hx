package exec;

import interp.ExecutionScope;
import haxe.ds.StringMap;
import lang.MatchValue;
import lang.Types.Atom;
import lang.Types.Tuple;

using lang.AtomSupport;

class DefaultTermExecuter implements TermExecuter {

  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function execute(term:Tuple, scope: ExecutionScope):MatchValue {
    var values: Array<Dynamic> = term.value;
    var operator: MatchValue = values[0];
    var context: MatchValue = values[1];
    var args: MatchValue = values[2];

    var realm: Atom = context.value.value[0].value;
    if(realm == ("native".atom())) {
      var className: Dynamic = context.value.value[1].value.value;
      var clazz: Dynamic = Type.resolveClass(className);
      var fun = Reflect.field(clazz, operator.value.value);
      var params: Array<Dynamic> = [args.value.value[0].value, args.value.value[1].value];
      return Reflect.callMethod(clazz, fun, params);
    }

    return null;
  }
}
