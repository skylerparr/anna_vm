package vm;
import lang.MatchValue;
import haxe.ds.GenericStack;
import exec.TermExecuter;

typedef FunctionStack = {
  index: Int,
  terms: Array<MatchValue>,
  inScopeVars: Map<String, MatchValue>
}

class SimpleProcess implements Process {

  @inject
  public var executer: TermExecuter;

  private var stack: GenericStack<Dynamic>;

  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function execute():Void {
  }
}
