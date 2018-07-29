package interp;
import interp.DefaultDataStructureInterpreter.ParsingState;
import lang.MatchType;
import lang.MatchData;
import lang.Types;
import lang.Types.Atom;
import lang.Types.Tuple;
import error.UnableToInterpretStringError;
import util.MatcherSupport;
import lang.MatchValue;

using hx.strings.Strings;

enum ParsingState {
  NONE;
  NUMBER;
  STRING;
  ATOM;
  TUPLE;
  LIST;
  MAP;
}

typedef Parse = {
  string: String,
  origString: String,
  currentIndex: Int,
  state: ParsingState,
  matchValue: MatchValue
}

class DefaultDataStructureInterpreter implements DataStructureInterpreter {

  private static var empty = ~/\s/;
  private static var number = ~/[0-9]/;
  private static var string = ~/[a-zA-Z]/;
  private static var quote = ~/"/;
  private static var colon = ~/:/;
  private static var open_brace = ~/\{/;
  private static var close_brace = ~/\}/;
  private static var comma = ~/,/;
  private static inline var OPEN_BRACKET: String = "[";
  private static inline var CLOSE_BRACKET: String = "]";

  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function encode(data:String):MatchValue {
    data = data + " ";
    var parse: Parse = {string: data, origString: data, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
    doEncode(parse);
    return parse.matchValue;
  }

  private inline function doEncode(parse: Parse): Void {
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
          parse.matchValue = MatcherSupport.getMatcher({value: currentVal, type: Types.ATOM});
          break;
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
        }
      }
      if(quote.match(char)) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.STRING;
          continue;
        } else if(parse.state == ParsingState.STRING) {
          parse.matchValue = MatcherSupport.getMatcher(currentVal);
          parse.state = ParsingState.NONE;
          break;
        } else if(parse.state == ParsingState.ATOM) {
          var atomParse: Parse = {string: currentStr.substring(parse.currentIndex), origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(atomParse);
          parse.matchValue = MatcherSupport.getMatcher({value: atomParse.matchValue.value, type: Types.ATOM});
          parse.state = ParsingState.NONE;
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
      if(colon.match(char)) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.ATOM;
          continue;
        }
      }
      if(open_brace.match(char)) {
        if(parse.state == ParsingState.NONE) {
          parse.state = ParsingState.TUPLE;
          parse.matchValue = MatcherSupport.getComplexMatcher({value: [], type: Types.TUPLE});
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var tupleParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(tupleParse);
          parse.currentIndex += tupleParse.currentIndex;
          parse.matchValue.value.value.push(tupleParse.matchValue);
          continue;
        }
      }
      if(close_brace.match(char)) {
        if(parse.state == ParsingState.NONE) {
          parse.matchValue = MatcherSupport.getComplexMatcher({value: [], type: Types.TUPLE});
          break;
        } else if(parse.state == ParsingState.TUPLE) {
          parse.state = ParsingState.NONE;
          parse.matchValue = parse.matchValue;
          parse.currentIndex++;
          break;
        } else if(parse.state == ParsingState.ATOM) {
          parse.matchValue = MatcherSupport.getMatcher({value: currentVal, type: Types.ATOM});
          parse.currentIndex++;
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
          doEncode(listParse);
          parse.currentIndex += listParse.currentIndex;
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
          parse.matchValue = parse.matchValue;
          parse.currentIndex++;
          break;
        } else if(parse.state == ParsingState.ATOM) {
          parse.matchValue = MatcherSupport.getMatcher({value: currentVal, type: Types.ATOM});
          parse.currentIndex++;
          break;
        }
      }
      if(comma.match(char)) {
        if(parse.state == ParsingState.TUPLE) {
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var tupleParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(tupleParse);
          parse.currentIndex += tupleParse.currentIndex - 1;
          parse.matchValue.value.value.push(tupleParse.matchValue);
          continue;
        } else if(parse.state == ParsingState.LIST) {
          var newString: String = currentStr.substring(parse.currentIndex + 1);
          var listParse: Parse = {string: newString, origString: currentStr, currentIndex: -1, state: ParsingState.NONE, matchValue: null};
          doEncode(listParse);
          parse.currentIndex += listParse.currentIndex - 1;
          parse.matchValue.value.value.add(listParse.matchValue);
          continue;
        } else if(parse.state == ParsingState.ATOM) {
          parse.matchValue = MatcherSupport.getMatcher({value: currentVal, type: Types.ATOM});
          break;
        } else if(parse.state == ParsingState.NUMBER) {
          parseNumber(currentVal, parse);
          break;
        }
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

  public function toString(data:MatchValue):String {
    var retVal = '${data.value}';
    return retVal;
  }
}
