package vm;
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
  public var mailbox: List<MatchValue>;

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
    var term:MatchValue = args[0];
    var scope: ExecutionScope = args[1];

    stack = new GenericStack<FunctionStack>();
    mailbox = new List<MatchValue>();

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
    var functionStack: FunctionStack = stack.first();
    if(functionStack == null) {
        kernel.endProcess(this);
    } else {
      var term: MatchValue = functionStack.terms[functionStack.index];

      if(term == null) {
        if(stack.first() != null) {
          stack.pop();
          if(stack.isEmpty()) {
            kernel.endProcess(this);
            status = ProcessStatus.STOPPED;
          }
        }
      } else {
        var result: ExecutionResult = executer.execute(term.value, functionStack.scope, mailbox);
        switch result.type {
          case ResultType.PUSH_STACK:
            pushStack(functionStack, result);
          case ResultType.CONSTANT:
            functionStack.scope.put("$result$", result.value);
          case ResultType.WAITING:
            status = ProcessStatus.WAITING;
            kernel.processWaiting(this);
          case ResultType.ERROR:
            status = ProcessStatus.STOPPED;
            kernel.processError(this);
        }
        functionStack.index++;
      }
    }
  }

  private inline function pushStack(functionStack: FunctionStack, result: ExecutionResult): Void {
    var results: Array<MatchValue> = cast result.value.value.value[1].value.value;
    var scope: ExecutionScope = objectCreator.createInstance(ExecutionScope);
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

  public function receiveMessage(matchValue:MatchValue):Void {
    mailbox.add(matchValue);
  }

}
