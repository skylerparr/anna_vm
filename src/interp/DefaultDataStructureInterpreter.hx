package interp;

import lang.MatchValue;

using hx.strings.Strings;

class DefaultDataStructureInterpreter implements DataStructureInterpreter {

  @inject
  public var stringDecoder: StringDecoder;

  @inject
  public var stringEncoder: StringEncoder;

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {

  }

  public function dispose():Void {
    stringDecoder = null;
    stringEncoder = null;
  }

  public function decode(data:String, scope: ExecutionScope):MatchValue {
    return stringDecoder.decode(data, scope);
  }

  public function toString(data:MatchValue):String {
    return stringEncoder.toString(data);
  }
}
