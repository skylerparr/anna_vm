package interp;

import core.BaseObject;
interface ExecutionScope extends BaseObject {
  function get(varName: String): Dynamic;
  function put(varName:String, value:Dynamic):Void;
  function print(): Void;
}