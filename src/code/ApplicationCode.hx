package code;

import lang.Types.Atom;
import lang.Types.Tuple;
import lang.MatchValue;
import core.BaseObject;

enum AccessModifier {
  PUBLIC;
  PRIVATE;
}

interface ApplicationCode extends BaseObject {
  function define(module: Atom, func: Atom, accessModifier: AccessModifier, args: MatchValue, block: Array<MatchValue>): Tuple;
  function getCode(module: Atom, func: Atom, args: Tuple): MatchValue;
  function publicFunctions(module: Atom): Array<Atom>;
}