package interp;
import lang.MatchType;
import lang.MatchData;
import util.MapUtil;
import error.UnsupportedError;
import lang.MatchValue;
import error.UnableToInterpretStringError;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import lang.MatchValue;
import lang.Types;
import util.MatcherSupport;

using hx.strings.Strings;
using lang.AtomSupport;

enum ParsingState {
  NONE;
  NUMBER;
  STRING;
  ATOM;
  TUPLE;
  LIST;
  MAP;
  VARIABLE;
  REFERENCE;
}

typedef Parse = {
string: String,
origString: String,
currentIndex: Int,
state: ParsingState,
matchValue: MatchValue
}

class StringDecoder implements DataStructureInterpreter {

  private static var empty = ~/\s/;
  private static var number = ~/[\-0-9]/;
  private static var string = ~/[a-zA-Z]/;
  private static inline var QUOTE = "\"";
  private static inline var COLON = ":";
  private static inline var OPEN_BRACE = "{";
  private static inline var CLOSE_BRACE = "}";
  private static inline var COMMA = ",";
  private static inline var OPEN_BRACKET: String = "[";
  private static inline var CLOSE_BRACKET: String = "]";
  private static inline var PERCENT: String = "%";
  private static inline var HASH: String = "#";
  private static inline var CHEVRON_OPEN: String = "<";
  private static inline var CHEVRON_CLOSE: String = ">";

  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function decode(data:String, scope: ExecutionScope):MatchValue {
    data = data + " ";
    var parse: Parse = {string: data, origString: data, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
    doEncode(parse, scope);
    return parse.matchValue;
  }

  private inline function doEncode(parse: Parse, scope: ExecutionScope): Void {
    var currentStr: String = parse.string;
    var strLength: Int = currentStr.length;

    var currentVal: String = "";

    while(parse.currentIndex < strLength) {
      parse.currentIndex++;

      var char: String = currentStr.charAt(parse.currentIndex);

      if(empty.match(char)) {
        if(parse.state == ParsingState.NONE) {
          continue;
        } else if(parse.state == ParsingState.NUMBER) {
          parseNumber(currentVal, parse);
          break;
        } else if(parse.state == ParsingState.ATOM) {
          parse.matchValue = MatcherSupport.getMatcher(currentVal.atom());
          break;
        } else if(parse.state == ParsingState.VARIABLE) {
          parse.state = ParsingState.NONE;
          parse.matchValue = MatcherSupport.getMatcherAssign(currentVal.trim());
          break;
        }
      }
      if(string.match(char)) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.VARIABLE;
          currentVal = currentVal + char;
          continue;
        }
      }
      if(number.match(char)) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.NUMBER;
          currentVal = char;
          continue;
        } else if(parse.state == ParsingState.NONE) {
          currentVal = currentVal + char;
          continue;
        } else if(parse.state == ParsingState.VARIABLE) {
          throw new UnableToInterpretStringError('Unexpected character');
        }
      }
      if(char == QUOTE) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.STRING;
          continue;
        } else if(parse.state == ParsingState.STRING) {
          parse.matchValue = MatcherSupport.getMatcher(currentVal);
          parse.state = ParsingState.NONE;
          break;
        } else if(parse.state == ParsingState.ATOM) {
          var atomParse: Parse = {string: currentStr.substring(parse.currentIndex), origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(atomParse, scope);
          var atomName: String = atomParse.matchValue.value;
          var atom: Atom = atomName.atom();
          parse.matchValue = MatcherSupport.getMatcher(atom);
          parse.state = ParsingState.NONE;
          parse.currentIndex += atomParse.currentIndex;
          break;
        }
      }
      if(string.match(char)) {
        if(parse.state == ParsingState.NONE) {
          throw new UnableToInterpretStringError('Unable to parse ${currentVal} in context.');
        } else if(parse.state == ParsingState.STRING) {
          currentVal = currentVal + char;
          continue;
        }
      }
      if(char == COLON) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.ATOM;
          continue;
        }
      }
      if(char == OPEN_BRACE) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.TUPLE;
          parse.matchValue = MatcherSupport.getComplexMatcher({value: [], type: Types.TUPLE});
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var tupleParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(tupleParse, scope);
          parse.currentIndex += tupleParse.currentIndex;
          if(tupleParse.matchValue != null) {
            parse.matchValue.value.value.push(tupleParse.matchValue);
          }
          continue;
        } else if(parse.state == ParsingState.MAP) {
          parse.matchValue = MatcherSupport.getComplexMatcher({value: null, type: Types.MAP});
          parseMap(currentStr, parse, scope);
          continue;
        }
      }
      if(char == CLOSE_BRACE) {
        if(parse.state == ParsingState.NONE) {
          parse.matchValue = null;
          break;
        } else if(parse.state == ParsingState.TUPLE) {
          parse.state = ParsingState.NONE;
          parse.currentIndex++;
          break;
        } else if(parse.state == ParsingState.MAP) {
          parse.state = ParsingState.NONE;
          parse.currentIndex++;
          break;
        } else if(parse.state == ParsingState.ATOM) {
          parse.state = ParsingState.NONE;
          parse.matchValue = MatcherSupport.getMatcher(currentVal.atom());
          break;
        } else if(parse.state == ParsingState.NUMBER) {
          parse.state = ParsingState.NONE;
          parseNumber(currentVal, parse);
          break;
        } else if(parse.state == ParsingState.VARIABLE) {
          parse.state = ParsingState.NONE;
          parse.matchValue = MatcherSupport.getMatcherAssign(currentVal.trim());
          break;
        }
      }
      if(char == OPEN_BRACKET) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.LIST;
          var list:List<Dynamic> = new List<Dynamic>();
          parse.matchValue = MatcherSupport.getComplexMatcher({value: list, type: Types.LIST});
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var listParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(listParse, scope);
          parse.currentIndex += listParse.currentIndex - 1;
          if(listParse.matchValue != null) {
            parse.matchValue.value.value.add(listParse.matchValue);
          }
          continue;
        }
      }
      if(char == CLOSE_BRACKET) {
        if(parse.state == ParsingState.NONE) {
          parse.matchValue = null;
          break;
        } else if(parse.state == ParsingState.LIST) {
          parse.state = ParsingState.NONE;
          parse.currentIndex++;
          break;
        } else if(parse.state == ParsingState.ATOM) {
          parse.matchValue = MatcherSupport.getMatcher(currentVal.atom());
          parse.currentIndex++;
          break;
        } else if(parse.state == ParsingState.VARIABLE) {
          parse.matchValue = MatcherSupport.getMatcherAssign(currentVal.trim());
          parse.currentIndex++;
          break;
        }
      }
      if(char == COMMA) {
        if(parse.state == ParsingState.TUPLE) {
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var tupleParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(tupleParse, scope);
          parse.currentIndex += tupleParse.currentIndex;
          parse.matchValue.value.value.push(tupleParse.matchValue);
          continue;
        } else if(parse.state == ParsingState.LIST) {
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var listParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(listParse, scope);
          parse.currentIndex += listParse.currentIndex;
          parse.matchValue.value.value.add(listParse.matchValue);
          continue;
        } else if(parse.state == ParsingState.MAP) {
          parseMap(currentStr, parse, scope);
          continue;
        } else if(parse.state == ParsingState.ATOM) {
          parse.matchValue = MatcherSupport.getMatcher(currentVal.atom());
          break;
        } else if(parse.state == ParsingState.NUMBER) {
          parseNumber(currentVal, parse);
          break;
        } else if(parse.state == ParsingState.VARIABLE) {
          parse.matchValue = MatcherSupport.getMatcherAssign(currentVal.trim());
          break;
        }
      }
      if(char == PERCENT) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.MAP;
        }
      }
      if(char == HASH) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.REFERENCE;
          parse.matchValue = {type: MatchType.REFERENCE, varName: null, value: null};
          continue;
        }
      }
      if(char == CHEVRON_OPEN && parse.state == ParsingState.REFERENCE) {
        parse.matchValue.value = currentVal;
        currentVal = "";
        continue;
      }
      if(char == CHEVRON_CLOSE && parse.state == ParsingState.REFERENCE) {
        parse.matchValue.varName = currentVal;
        parse.matchValue.value = scope.get(currentVal);
        break;
      }
      currentVal = currentVal + char;
    }
    if(parse.state == ParsingState.STRING) {
      throw new UnableToInterpretStringError('Unexpected end of line');
    }
  }

  private inline function parseNumber(currentVal: String, parse: Parse): Void {
    parse.state = ParsingState.NONE;
    if(currentVal.contains(".")) {
      var val: Float = Std.parseFloat(currentVal);
      parse.matchValue = MatcherSupport.getMatcher(val);
    } else if(Std.parseInt(currentVal) == null) {
      throw new UnableToInterpretStringError('Unable to cast ${currentVal} to integer.');
    } else {
      var val: Int = Std.parseInt(currentVal);
      parse.matchValue = MatcherSupport.getMatcher(val);
    }
  }

  private inline function parseMap(currentStr: String, parse: Parse, scope: ExecutionScope): Void {
    var newString: String = currentStr.substring(parse.currentIndex + 1);
    var mapKey: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
    doEncode(mapKey, scope);
    parse.currentIndex += mapKey.currentIndex;
    if(mapKey.matchValue == null) {
      parse.matchValue = MatcherSupport.getComplexMatcher({value: new ObjectMap<Dynamic, Dynamic>(), type: Types.MAP});
    } else {
      var key: Dynamic = mapKey.matchValue.value;
      var map = parse.matchValue.value.value;
      if(Std.is(key, String) && map == null) {
        parse.matchValue.value = {value: new StringMap<MatchValue>(), type: Types.MAP};
      } else if(map == null) {
        parse.matchValue.value = {value: new ObjectMap<Dynamic, MatchValue>(), type: Types.MAP};
      }

      var newString: String = currentStr.substring(parse.currentIndex + 5);
      var mapValue: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
      doEncode(mapValue, scope);
      parse.currentIndex += mapValue.currentIndex + 4;

      var map: Map<Dynamic, Dynamic> = parse.matchValue.value.value;
      if(Reflect.hasField(mapValue.matchValue.value, "value")) {
        map.set(mapKey.matchValue.value, MatcherSupport.getComplexMatcher(mapValue.matchValue.value));
      } else if(mapValue.matchValue.varName == "") {
        map.set(mapKey.matchValue.value, MatcherSupport.getMatcher(mapValue.matchValue.value));
      } else if(mapValue.matchValue.varName != "") {
        map.set(mapKey.matchValue.value, mapValue.matchValue);
      }
    }
  }

  public function toString(data:MatchValue):String {
    throw new UnsupportedError("Not implemented for this class");
  }

}
