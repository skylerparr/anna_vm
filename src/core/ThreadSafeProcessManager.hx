package core;
import lang.MatchValue;
import interp.ExecutionScope;
import hx.concurrent.collection.SynchronizedLinkedList;
import vm.Process;
class ThreadSafeProcessManager implements ProcessManager {

  @inject
  public var objectCreator: ObjectCreator;
  
  public var processess: SynchronizedLinkedList<Process>;

  public function new() {
  }

  public function init(args:Array<Dynamic> = null):Void {
    processess = new SynchronizedLinkedList<Process>();
  }

  public function dispose():Void {
    objectCreator = null;
    processess = null;
  }

  public function startProcess(parentProcess:Process, fun:MatchValue, scope:ExecutionScope):Process {
    var process: Process = objectCreator.createInstance(Process, [], [fun, scope]);
    process.parentProcess = parentProcess;
    parentProcess.addChildProcess(process);
    processess.add(process);
    return process;
  }

  public function getNext():Process {
    var retVal: Process = processess.removeLast();
    processess.add(retVal);
    return retVal;
  }

  public function killProcess(process:Process):Void {
    for(child in process.childProcesses) {
      termProcess(child);
    }
    termProcess(process);
  }

  public function termProcess(process:Process):Void {
    process.setStopped();
    processess.remove(process);
  }

  public function allProcesses(): List<Process> {
    var retVal: List<Process> = new List<Process>();
    for(p in processess) {
      retVal.add(p);
    }
    return retVal;
  }
}
