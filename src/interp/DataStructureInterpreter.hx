package interp;

import core.BaseObject;
import lang.MatchValue;

interface DataStructureInterpreter extends BaseObject {
  function decode(data: String, scope: ExecutionScope): MatchValue;
  function toString(data: MatchValue): String;
}
