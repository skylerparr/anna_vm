package util;
import haxe.ds.ObjectMap;

class MapUtil {
  public function new() {
  }

  public static inline function mapSize(map: Map<Dynamic, Dynamic>):Int {
    var count: Int = 0;
    for(map in map.iterator()) {
      count++;
    }
    return count;
  }

  public static inline function printKeys(map: Map<Dynamic, Dynamic>): Void {
    for(key in map.keys()) {
      trace(key);
    }
  }

  public static inline function firstKey(map: Map<Dynamic, Dynamic>): Dynamic {
    var retVal: Dynamic = null;
    for(key in map.keys()) {
      retVal = key;
      break;
    }
    return retVal;
  }
}
