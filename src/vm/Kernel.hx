package vm;

import lang.MatchValue;
import lang.MatchData;
import lang.Types.Tuple;
import core.BaseObject;
import lang.Types.Atom;

interface Kernel extends BaseObject {
  function spawnProcess(matchValue: MatchValue): Process;
  function endProcess(process: Process): Void;
  function processError(process: Process): Void;

  function apply(module: Atom, fun: Atom, args: Tuple): MatchValue;
  function receive(process: Process): MatchValue;
}