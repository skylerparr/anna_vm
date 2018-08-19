package interp;

import haxe.ds.StringMap;
using lang.AtomSupport;

class StringMapExecutionScope implements ExecutionScope {

  public var varMap: StringMap<Dynamic> = new StringMap<Dynamic>();

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
  }

  public function dispose():Void {
    varMap = null;
  }

  public function put(varName:String, value:Dynamic):Void {
    varMap.set(varName, value);
  }

  public function get(varName:String):Dynamic {
    if(varMap.exists(varName)) {
      return varMap.get(varName);
    } else {
      return "nil".atom();
    }
  }
}