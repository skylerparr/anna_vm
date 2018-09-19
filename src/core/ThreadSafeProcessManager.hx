package core;
import hx.concurrent.collection.SynchronizedLinkedList;
import cpp.vm.Deque;
import vm.Process;
class ThreadSafeProcessManager implements ProcessManager {

  public var processess: SynchronizedLinkedList<Process>;

  public function new() {
  }

  public function init(args:Array<Dynamic> = null):Void {
    processess = new SynchronizedLinkedList<Process>();
  }

  public function dispose():Void {
    processess = null;
  }

  public function storeProcess(process:Process):Void {
    processess.add(process);
  }

  public function getNext():Process {
    var retVal: Process = processess.removeLast();
    processess.add(retVal);
    return retVal;
  }

  public function killProcess(process:Process):Void {
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
