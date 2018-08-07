package interp;
import lang.MatchValue;

using hx.strings.Strings;

class DefaultDataStructureInterpreter implements DataStructureInterpreter {

  @inject
  public var stringDecoder: StringDecoder;

  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function decode(data:String):MatchValue {
    return stringDecoder.decode(data);
  }

  public function toString(data:MatchValue):String {
    var retVal = '${data.value}';
    return retVal;
  }
}
