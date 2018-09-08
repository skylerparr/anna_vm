package exec;

import vm.Process;
import lang.MatchType;
import vm.Kernel;
import util.MatcherSupport;
import vm.ExecutionResult;
import interp.ExecutionScope;
import lang.MatchValue;
import lang.Types.Atom;
import lang.Types.Tuple;

using lang.AtomSupport;

class DefaultTermExecuter implements TermExecuter {

  @inject
  public var kernel: Kernel;

  public function new() {
  }

  public function init(args: Array<Dynamic> = null):Void {
  }

  public function dispose():Void {
  }

  public function execute(term:Tuple, process: Process, scope: ExecutionScope, mailbox: List<MatchValue>):ExecutionResult {
    var values: Array<Dynamic> = term.value;
    var operator: MatchValue = values[0];
    var context: MatchValue = values[1];
    var args: MatchValue = values[2];

    var realm: Atom = context.value.value[0].value;
    if(realm == ("native".atom())) {
      var className: Dynamic = context.value.value[1].value.value;
      var clazz: Dynamic = Type.resolveClass(className);
      var fun = Reflect.field(clazz, operator.value.value);
      var params: Array<Dynamic> = [];
      var argParams: Array<Dynamic> = cast args.value.value;
      for(arg in argParams) {
        if(arg.type == MatchType.VARIABLE) {
          params.push(scope.get(arg.varName));
        } else {
          params.push(arg.value);
        }
      }
      if(clazz != null && fun != null && params != null) {
        try {
          var funResult: Dynamic = Reflect.callMethod(clazz, fun, params);
          return {type: ResultType.CONSTANT, value: MatcherSupport.getMatcher(funResult)};
        } catch(e: Dynamic) {
          return {type: ResultType.ERROR, value: MatcherSupport.getMatcher(e)};
        }
      } else {
        return {type: ResultType.ERROR, value: MatcherSupport.getMatcher('Unable to execute native function. class: ${clazz}, function: ${fun}, args: ${params}')};
      }
    } else if(realm == ("anna".atom())) {
      var mod: Atom = term.value[0].value;
      var fun: Atom = context.value.value[1].value;
      var args: Tuple = term.value[2];

      try {
        var funResult: MatchValue = kernel.apply(process, mod, fun, args);
        return {type: ResultType.PUSH_STACK, value: funResult};
      } catch(e: Dynamic) {
        return {type: ResultType.ERROR, value: MatcherSupport.getMatcher(e)};
      }
    }

    return {type: ResultType.ERROR, value: MatcherSupport.getMatcher("Unable to execute")};
  }
}
