package vm;
import hx.concurrent.collection.SynchronizedLinkedList;
import vm.FunctionStack;
import core.ObjectCreator;
import exec.TermExecuter;
import haxe.ds.GenericStack;
import interp.ExecutionScope;
import lang.MatchValue;
import vm.ExecutionResult.ResultType;

class SimpleProcess implements Process {

  @inject
  public var executer: TermExecuter;
  @inject
  public var kernel: Kernel;
  @inject
  public var objectCreator: ObjectCreator;

  @:isVar
  public var status(get, null): ProcessStatus;
  private function get_status(): ProcessStatus {
    return status;
  }

  public var stack: GenericStack<FunctionStack>;
  public var mailbox: SynchronizedLinkedList<MatchValue>;

  @:isVar
  public var parentProcess(get, set): Process;

  private function get_parentProcess():Process {
    return parentProcess;
  }

  private function set_parentProcess(value:Process):Process {
    return this.parentProcess = value;
  }

  private var childrenProcesses: SynchronizedLinkedList<Process>;

  public var childProcesses(get, null):Array<Process>;

  function get_childProcesses():Array<Process> {
    return childrenProcesses.toArray();
  }

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
    var term:MatchValue = args[0];
    var scope: ExecutionScope = args[1];
    scope.put("$currentProcess$", this);

    stack = new GenericStack<FunctionStack>();
    mailbox = new SynchronizedLinkedList<MatchValue>();
    childrenProcesses = new SynchronizedLinkedList<Process>();

    var funStack: FunctionStack = new FunctionStack([term], scope);
    stack.add(funStack);

    status = ProcessStatus.RUNNING;
  }

  public function dispose():Void {
    executer = null;
    kernel = null;
    objectCreator = null;
    stack = null;
    mailbox = null;
    status = ProcessStatus.DESTROYED;
  }

  public inline function execute():Void {
    status = ProcessStatus.RUNNING;

    var functionStack: FunctionStack = stack.first();
    if(functionStack == null) {
      kernel.endProcess(this);
      setStopped();
    } else {
      var term: MatchValue = functionStack.terms[functionStack.index];
      if(term == null) {
        if(stack.first() != null) {
          stack.pop();
          if(stack.isEmpty()) {
            kernel.endProcess(this);
            setStopped();
          }
        }
      } else {
        var result: ExecutionResult = executer.execute(term.value, this, functionStack.scope);
        switch result.type {
          case ResultType.PUSH_STACK:
            pushStack(functionStack, result);
          case ResultType.CONSTANT:
            functionStack.scope.put("$result$", result.value);
          case ResultType.ERROR:
            setStopped();
            kernel.processError(this);
        }
        functionStack.index++;
      }
    }
  }

  private inline function pushStack(functionStack: FunctionStack, result: ExecutionResult): Void {
    var results: Array<MatchValue> = cast result.value.value.value[1].value.value;
    var scope: ExecutionScope = objectCreator.createInstance(ExecutionScope);
    scope.put("$currentProcess$", this);
    var terms: Array<MatchValue> = [];
    for(matchValue in results) {
      terms.push(matchValue);
    }
    if(functionStack.terms.length >= functionStack.index) {
      stack.pop();
    }

    var funStack: FunctionStack = new FunctionStack(terms, scope);
    stack.add(funStack);
  }

  public function addChildProcess(process:Process):Void {
    childrenProcesses.add(process);
  }

  public function removeChildProcess(process:Process):Void {
    childrenProcesses.remove(process);
  }

  public function receiveMessage(matchValue:MatchValue):Void {
    mailbox.add(matchValue);
  }

  public function setWaiting():Void {
    status = ProcessStatus.WAITING;
  }

  public function setStopped():Void {
    status = ProcessStatus.STOPPED;
  }

  public function send(matchValue:MatchValue):Void {
    mailbox.add(matchValue);
  }

}
