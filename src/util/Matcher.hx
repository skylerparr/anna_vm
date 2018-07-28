package util;
import lang.Types;
import lang.MatchType;
import lang.MatchData;
import lang.MatchValue;
import haxe.ds.ObjectMap;
class Matcher {
  public static inline function match(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>):MatchData {
    return tryMatch(left, right, scope, new Map<String, Dynamic>());
  }

  private static function tryMatch(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    switch(left.type) {
      case MatchType.CONSTANT:
        //weird, can only test on equality
        if (left.value == right) {
          //empty on purpose
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

  private static function matchHeadTail(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
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

  private static function matchComplex(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    if (right.type == Types.TUPLE && left.value.type == Types.TUPLE) {
      return matchTuple(left, right, scope, matchedVars);
    }
    if (right.type == Types.LIST && left.value.type == Types.LIST) {
      return matchList(left, right, scope, matchedVars);
    }
    if (right.type == Types.MAP && left.value.type == Types.MAP) {
      var mapRight:ObjectMap<Dynamic, Dynamic> = cast(right.value, ObjectMap<Dynamic, Dynamic>);
      var mapLeft:ObjectMap<Dynamic, Dynamic> = cast(left.value.value, ObjectMap<Dynamic, Dynamic>);

      var matchData:MatchData = {matched: true, matchedVars: matchedVars};
      for (key in mapLeft.keys()) {
        var keyValue:Dynamic = key.value;
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
    return {matched: false, matchedVars: matchedVars};
  }

  private static inline function matchTuple(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var arrayRight:Array<Dynamic> = cast(right.value, Array<Dynamic>);
    var arrayLeft:Array<Dynamic> = cast(left.value.value, Array<Dynamic>);

    var matchData:MatchData = {matched: true, matchedVars: matchedVars};
    for (i in 0...arrayRight.length) {
      matchData = tryMatch(arrayLeft[i], arrayRight[i], scope, matchedVars);
      if (!matchData.matched) {
        updateUnmatched(matchData);
        break;
      }
    }
    return matchData;
  }

  private static inline function matchList(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var listRight:List<Dynamic> = cast(right.value, List<Dynamic>);
    var listLeft:List<Dynamic> = cast(left.value.value, List<Dynamic>);

    var matchData:MatchData = {matched: true, matchedVars: matchedVars};
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

  private static inline function updateUnmatched(matchData: MatchData): Void {
    matchData.matched = false;
    matchData.matchedVars = null;
  }
}
