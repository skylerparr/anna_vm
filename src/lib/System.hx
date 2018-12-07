package lib;
import lang.MatchValue;
import interp.ExecutionScope;
import vm.Process;
import vm.Kernel;
class System {

  @inject
  public var kernel: Kernel;

  public function new() {
  }

  public static function spawnProcess(parentProcess: Process, fun:MatchValue, scope: ExecutionScope):Process {
    return kernel.spawnProcess(parentProcess, fun, scope);
  }

  public static function send(process: Process, data: MatchValue): Void {
    kernel.send(process, data)
  }

  public static function receive(process: Process): MatchValue {
    // ?
  }

}
