package matcher;
import util.MatcherSupport;
import util.MapUtil;
import lang.Types;
import lang.MatchType;
import lang.MatchData;
import lang.MatchValue;
import haxe.ds.ObjectMap;

class DefaultMatcher implements Matcher {

  public function new() {
  }

  public function match(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>):MatchData {
    return tryMatch(left, right, scope, new Map<String, Dynamic>());
  }

  private inline function tryMatch(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var matchData: MatchData = {matched: true, matchedVars: matchedVars};
    switch(left.type) {
      case MatchType.CONSTANT:
        if (left.value == right) {
          matchData = {matched: true, matchedVars: matchedVars};
        } else {
          if(Reflect.hasField(right, "type") && left.value.type == right.type && left.value.value == right.value) {
            matchData = {matched: true, matchedVars: matchedVars};
          } else {
            matchData = {matched: false, matchedVars: null};
          }
        }
      case MatchType.VARIABLE:
        matchedVars.set(left.varName, right);
      case MatchType.COMPLEX:
        matchData = matchComplex(left, right, scope, matchedVars);
      case MatchType.HEAD_TAIL:
        matchData = matchHeadTail(left, right, scope, matchedVars);
    }
    return matchData;
  }

  private inline function matchHeadTail(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var listLeft:Array<Dynamic> = cast(left.value, Array<Dynamic>);
    var listRight:List<Dynamic> = cast(right.value, List<Dynamic>);

    var matchData:MatchData = {matched: false, matchedVars: matchedVars};
    matchData = tryMatch(listLeft[0], listRight.pop(), scope, matchedVars);
    if (matchData.matched) {
      left = listLeft[1];
      matchData = tryMatch(left.value, right, scope, matchedVars);
    }
    return matchData;
  }

  private inline function matchComplex(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var matchData: MatchData = {matched: false, matchedVars: matchedVars};
    if (right.type == Types.TUPLE && left.value.type == Types.TUPLE) {
      matchData = matchTuple(left, right, scope, matchedVars);
    }
    if (right.type == Types.LIST && left.value.type == Types.LIST) {
      matchData = matchList(left, right, scope, matchedVars);
    }
    if (right.type == Types.MAP && left.value.type == Types.MAP) {
      matchData = matchMap(left, right, scope, matchedVars);
    }
    return matchData;
  }

  private inline function matchTuple(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>, matchedVars:Map<String, Dynamic>):MatchData {
    var arrayRight:Array<Dynamic> = cast(right.value, Array<Dynamic>);
    var arrayLeft:Array<Dynamic> = cast(left.value.value, Array<Dynamic>);

    var matchData:MatchData = {matched: true, matchedVars: matchedVars};
    for (i in 0...arrayRight.length) {
      var left = arrayLeft[i];
      var right = arrayRight[i];

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
    var matchData:MatchData = {matched: true, matchedVars: matchedVars};

    var mapRight:Map<Dynamic, Dynamic> = cast(right.value, Map<Dynamic, Dynamic>);
    var mapLeft:Map<Dynamic, Dynamic> = cast(left.value.value, Map<Dynamic, Dynamic>);

    if(MapUtil.first(mapLeft) == null && MapUtil.first(mapRight) != null) {
      updateUnmatched(matchData);
    } else {
      for (key in mapLeft.keys()) {
        var keyValue: Dynamic = key;

        if (mapRight.exists(keyValue)) {
          var matchData:MatchData = tryMatch(mapLeft.get(key), mapRight.get(keyValue), scope, matchedVars);
          if (!matchData.matched) {
            updateUnmatched(matchData);
          }
        } else {
          updateUnmatched(matchData);
        }
      }
    }

    return matchData;
  }
  
  private inline function updateUnmatched(matchData: MatchData): Void {
    matchData.matched = false;
    matchData.matchedVars = null;
  }

}
