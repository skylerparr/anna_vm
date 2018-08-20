package vm;

import lang.MatchValue;
import lang.Types.Atom;
import lang.Types.Tuple;

class DefaultKernel implements Kernel {

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
  }

  public function dispose():Void {
  }

  public function spawnProcess(matchValue:MatchValue):Process {
    return null;
  }

  public function endProcess(process:Process):Void {
  }

  public function processError(process:Process):Void {
  }

  public function apply(module:Atom, fun:Atom, args:Tuple):MatchValue {
    return null;
  }

  public function receive(process:Process):MatchValue {
    return null;
  }

}