package vm;

import vm.Process;
import interp.ExecutionScope;
import lang.MatchValue;
import lang.MatchData;
import lang.Types.Tuple;
import core.BaseObject;
import lang.Types.Atom;

interface Kernel extends BaseObject {
  function spawnProcess(process: Process, matchValue: MatchValue, scope: ExecutionScope): Process;
  function endProcess(process: Process): Void;
  function processError(process: Process): Void;

  function apply(process: Process, module: Atom, fun: Atom, args: MatchValue): MatchValue;
  function receive(process: Process): MatchValue;
}