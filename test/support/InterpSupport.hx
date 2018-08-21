package support;

import interp.DataStructureInterpreter;
import interp.DefaultDataStructureInterpreter;
import interp.StringDecoder;
import interp.StringEncoder;
class InterpSupport {
  public static inline function getInterpreter(): DataStructureInterpreter {
    var interp = new DefaultDataStructureInterpreter();
    interp.stringDecoder = new StringDecoder();
    interp.stringEncoder = new StringEncoder();
    interp.init();
    return interp;
  }
}