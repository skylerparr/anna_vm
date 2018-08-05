package util;
import haxe.ds.ObjectMap;

class MapUtil {
  public function new() {
  }

  public static inline function mapSize(map: ObjectMap<Dynamic, Dynamic>):Int {
    var count: Int = 0;
    for(map in map.iterator()) {
      count++;
    }
    return count;
  }

  public static inline function printKeys(map: ObjectMap<Dynamic, Dynamic>): Void {
    for(key in map.keys()) {
      trace(key);
    }
  }
}
