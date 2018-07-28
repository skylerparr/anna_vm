package util;
import lang.MatchType;
import lang.MatchValue;

class MatcherSupport {
  public static inline function getComplexMatcher(value:Dynamic):MatchValue {
    return {type: MatchType.COMPLEX, varName: null, value: value};
  }

  public static inline function getMatcher(value:Dynamic):MatchValue {
    return {type: MatchType.CONSTANT, varName: null, value: value};
  }

  public static inline function getMatcherAssign(varName:String):MatchValue {
    return {type: MatchType.VARIABLE, varName: varName, value: null};
  }
}
