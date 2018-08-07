package interp;
import lang.Types;
import lang.MatchType;
import error.UnsupportedError;
import lang.MatchValue;
class StringEncoder implements DataStructureInterpreter {
  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function toString(data:MatchValue):String {
    var retVal: String = "";
    switch data.type {
      case MatchType.CONSTANT:
        retVal = parseConstant(data.value);
      case MatchType.COMPLEX:
        retVal = parseComplex(data.value);
      case MatchType.HEAD_TAIL:
      case MatchType.VARIABLE:
    }
    return retVal;
  }

  private inline function parseConstant(value: Dynamic): String {
    var retVal: String = "";
    if(Reflect.hasField(value, "value")) {
      retVal = ':${value.value}';
    } else if(Std.is(value, String)) {
      retVal = '"${value}"';
    } else {
      retVal = '${value}';
    }
    return retVal;
  }

  private inline function parseComplex(value: Dynamic): String {
    var retVal: String = "";
    switch(value.type) {
      case Types.TUPLE:
        retVal += "{";
        var items: Array<MatchValue> = cast value.value;
        retVal += gatherNested(items);
        retVal += "}";
      case Types.LIST:
        retVal += "[";
        var items: List<MatchValue> = cast value.value;
        retVal += gatherNested(items);
        retVal += "]";
      case Types.MAP:
        retVal += "%{";
        retVal += parseMap(value.value);
        retVal += "}";
      case Types.ATOM:
        retVal = ":";
    }
    return retVal;
  }

  private inline function gatherNested(items: Iterable<Dynamic>): String {
    var strings: Array<String> = [];
    for(item in items) {
      strings.push(toString(item));
    }
    return strings.join(", ");
  }

  private inline function parseMap(value: Map<Dynamic, Dynamic>): String {
    var strings: Array<String> = [];
    for(key in value.keys()) {
      var value: MatchValue = value.get(key);
      strings.push('${parseConstant(key)} => ${toString(value)}');
    }
    return strings.join(", ");
  }

  public function decode(data:String):MatchValue {
    throw new UnsupportedError("Not implemented for this class");
  }
}
