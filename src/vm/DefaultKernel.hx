package vm;

import lang.MatchData;
import code.ApplicationCode;
import vm.Process;
import interp.ExecutionScope;
import core.ObjectCreator;
import lang.MatchValue;
import lang.Types.Atom;
import lang.Types.Tuple;

class DefaultKernel implements Kernel {

  @inject
  public var objectCreator: ObjectCreator;

  @inject
  public var applicationCode: ApplicationCode;

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
  }

  public function dispose():Void {
  }

  public function spawnProcess(parentProcess: Process, fun:MatchValue, scope: ExecutionScope):Process {
    return objectCreator.createInstance(Process, [], [fun, scope]);
  }

  public function endProcess(process:Process):Void {
    trace("end process");
  }

  public function processError(process:Process):Void {
  }

  public function apply(process: Process, module:Atom, fun:Atom, args:MatchValue):MatchValue {
    return applicationCode.getCode(module, fun, args);
  }

  public function receive(process:Process):MatchValue {
    return null;
  }

}