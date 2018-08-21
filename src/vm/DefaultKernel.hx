package vm;

import vm.Process;
import interp.ExecutionScope;
import core.ObjectCreator;
import lang.MatchValue;
import lang.Types.Atom;
import lang.Types.Tuple;

class DefaultKernel implements Kernel {

  @inject
  public var objectCreator: ObjectCreator;

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
  }

  public function dispose():Void {
  }

  public function spawnProcess(process: Process, matchValue:MatchValue, scope: ExecutionScope):Process {
    return null;
  }

  public function endProcess(process:Process):Void {
    trace("end process");
  }

  public function processError(process:Process):Void {
  }

  public function apply(process: Process, module:Atom, fun:Atom, args:Tuple):MatchValue {
    return null;
  }

  public function receive(process:Process):MatchValue {
    return null;
  }

}