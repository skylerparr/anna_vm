package interp;
import lang.MatchValue;
import core.BaseObject;
interface DataStructureInterpreter extends BaseObject {
  function decode(data: String): MatchValue;
  function toString(data: MatchValue): String;
}
