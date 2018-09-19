package code;

import matcher.Matcher;
import code.ApplicationCode.AccessModifier;
import lang.MatchValue;
import lang.Types.Atom;
import lang.Types.Tuple;
import lang.Types;
class DefaultApplicationCode implements ApplicationCode {

  @inject
  public var matcher: Matcher;

  public var moduleMap: Map<Atom, Map<Atom, Array<Tuple>>>;

  public function new() {
  }

  public function init(args:Array<Dynamic> = null):Void {
    moduleMap = new Map<Atom, Map<Atom, Array<Tuple>>>();
  }

  public function dispose():Void {
    matcher = null;
    moduleMap = null;
  }

  public function define(module:Atom, func:Atom, accessModifier:AccessModifier, args: MatchValue, block: MatchValue):Tuple {
    var functionDef: Tuple = {type: Types.TUPLE, value: [module, func, accessModifier, args, block]};

    var context: Array<Dynamic> = getContext(module, func);
    var functionMap: Map<Atom, Array<Tuple>> = context[0];
    var functions: Array<Tuple> = context[1];

    functions.push(functionDef);
    functionMap.set(func, functions);

    moduleMap.set(module, functionMap);
    return functionDef;
  }

  public function getCode(module:Atom, func:Atom, right: MatchValue):MatchValue {
    var context: Array<Dynamic> = getContext(module, func);
    var functionMap: Map<Atom, Array<Tuple>> = context[0];
    var functions: Array<Tuple> = context[1];

    for(fun in functions) {
      var left: MatchValue = fun.value[3];
      if(matcher.match(left, right.value).matched) {
        return fun.value[4];
      }
    }
    return null;
  }

  private inline function getContext(module: Atom, func: Atom): Array<Dynamic> {
    var functionMap: Map<Atom, Array<Tuple>> = moduleMap.get(module);
    if(functionMap == null) {
      functionMap = new Map<Atom, Array<Tuple>>();
    }

    var functions: Array<Tuple> = functionMap.get(func);
    if(functions == null) {
      functions = [];
    }
    return [functionMap, functions];
  }

  public function publicFunctions(module:Atom):Array<Atom> {
    return null;
  }
}