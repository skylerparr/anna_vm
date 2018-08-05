package matcher;
import util.MatcherSupport;
import util.MapUtil;
import lang.Types;
import lang.MatchType;
import lang.MatchData;
import lang.MatchValue;
import haxe.ds.ObjectMap;

enum MapType {
  STRING;
  OBJECT;
}

class DefaultMatcher implements Matcher {

  public function new() {
  }

  public inline function match(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>):MatchData {
    return tryMatch(left, right, scope, new Map<String, Dynamic>());
  }

  private function tryMatch(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    switch(left.type) {
      case MatchType.CONSTANT:
        if (left.value == right) {
          return {matched: true, matchedVars: matchedVars};
        } else {
          if(Reflect.hasField(right, "type") && left.value.type == right.type && left.value.value == right.value) {
            return {matched: true, matchedVars: matchedVars};
          } else {
            return {matched: false, matchedVars: null};
          }
        }
      case MatchType.VARIABLE:
        matchedVars.set(left.varName, right);
      case MatchType.COMPLEX:
        return matchComplex(left, right, scope, matchedVars);
      case MatchType.HEAD_TAIL:
        return matchHeadTail(left, right, scope, matchedVars);
    }
    return {matched: true, matchedVars: matchedVars};
  }

  private function matchHeadTail(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var listLeft:Array<Dynamic> = cast(left.value, Array<Dynamic>);
    var listRight:List<Dynamic> = cast(right.value, List<Dynamic>);

    var matchData:MatchData = {matched: false, matchedVars: matchedVars};
    matchData = tryMatch(listLeft[0], listRight.pop(), scope, matchedVars);
    @IgnoreCover //for some reason the code coverage tool is not picking this up
    if (matchData.matched) {
      left = listLeft[1];
      matchData = tryMatch(left.value, right, scope, matchedVars);
    }
    return matchData;
  }

  private function matchComplex(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    if (right.type == Types.TUPLE && left.value.type == Types.TUPLE) {
      return matchTuple(left, right, scope, matchedVars);
    }
    if (right.type == Types.LIST && left.value.type == Types.LIST) {
      return matchList(left, right, scope, matchedVars);
    }
    if (right.type == Types.MAP && left.value.type == Types.MAP) {
      return matchMap(left, right, scope, matchedVars);
    }
    return {matched: false, matchedVars: matchedVars};
  }

  private inline function matchTuple(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var arrayRight:Array<Dynamic> = cast(right.value, Array<Dynamic>);
    var arrayLeft:Array<Dynamic> = cast(left.value.value, Array<Dynamic>);

    var matchData:MatchData = {matched: true, matchedVars: matchedVars};
    for (i in 0...arrayRight.length) {
      var left = arrayLeft[i];
      var right = arrayRight[i];

      @IgnoreCover
      if(left == null || right == null) {
        updateUnmatched(matchData);
        break;
      }
      matchData = tryMatch(left, right, scope, matchedVars);
      if (!matchData.matched) {
        updateUnmatched(matchData);
        break;
      }
    }
    return matchData;
  }

  private inline function matchList(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var listRight:List<Dynamic> = cast(right.value, List<Dynamic>);
    var listLeft:List<Dynamic> = cast(left.value.value, List<Dynamic>);

    var matchData:MatchData = {matched: true, matchedVars: matchedVars};

    if(listLeft.length != listRight.length) {
      updateUnmatched(matchData);
      return matchData;
    }

    for (item in listLeft) {
      var rightItem:Dynamic = listRight.pop();
      matchData = tryMatch(item, rightItem, scope, matchedVars);
      if (!matchData.matched) {
        updateUnmatched(matchData);
        break;
      }
    }
    return matchData;
  }

  private inline function matchMap(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var matchData:MatchData;

    if(mapType(right.value) == MapType.STRING) {
      matchData = matchStringMap(left, right, scope, matchedVars);
    } else {
      matchData = matchObjectMap(left, right, scope, matchedVars);
    }
    return matchData;
  }

  private function matchStringMap(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var matchData:MatchData = {matched: true, matchedVars: matchedVars};

    var mapRight:Map<String, Dynamic> = cast(right.value, Map<String, Dynamic>);
    var mapLeft:Map<Dynamic, Dynamic> = cast(left.value.value, Map<Dynamic, Dynamic>);

    for (key in mapLeft.keys()) {
      var leftKeyValue: String = key.value;
    }
    return matchData;
  }

  private function matchObjectMap(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var matchData:MatchData = {matched: true, matchedVars: matchedVars};

    var mapRight:Map<Dynamic, Dynamic> = cast(right.value, Map<Dynamic, Dynamic>);
    var mapLeft:Map<Dynamic, Dynamic> = cast(left.value.value, Map<Dynamic, Dynamic>);

    for (key in mapLeft.keys()) {
      var keyValue: String = key.value;

      if (mapRight.exists(keyValue)) {
        var matchData:MatchData = tryMatch(mapLeft.get(key), mapRight.get(keyValue), scope, matchedVars);
        if (!matchData.matched) {
          updateUnmatched(matchData);
          return matchData;
        }
      } else {
        for (rightKey in mapRight.keys()) {
          var matchData:MatchData = tryMatch(key, rightKey, scope, matchedVars);
          if (matchData.matched) {
            return tryMatch(mapLeft.get(key), mapRight.get(keyValue), scope, matchData.matchedVars);
          }
        }
        updateUnmatched(matchData);
        break;
      }
    }
    return matchData;
  }

  private inline function mapType(map: Dynamic): MapType {
    var retVal = MapType.OBJECT;
    var key: Dynamic = MapUtil.firstKey(map);
    if(Std.is(key, String)) {
      retVal = MapType.STRING;
    }
    return retVal;
  }

  private inline function updateUnmatched(matchData: MatchData): Void {
    matchData.matched = false;
    matchData.matchedVars = null;
  }

}
