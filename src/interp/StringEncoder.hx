package interp;
import haxe.ds.StringMap;
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
      case MatchType.VARIABLE:
        retVal = parseVariable(data.varName);
      case MatchType.HEAD_TAIL:
      case MatchType.REFERENCE:
        retVal = parseReference(data);
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

  private inline function parseVariable(value: Dynamic): String {
    return '{:${value}, [], :var}';
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

  private function gatherNested(items: Iterable<Dynamic>): String {
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

  private inline function parseReference(value: MatchValue): String {
    var className: String = Type.getClassName(Type.getClass(value.value));
    return '#${className}<${value.varName}>';
  }

  public function decode(data:String, scope: ExecutionScope):MatchValue {
    throw new UnsupportedError("Not implemented for this class");
  }
}
