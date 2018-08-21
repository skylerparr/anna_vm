package exec;
import vm.Process;
import vm.ExecutionResult;
import core.BaseObject;
import interp.ExecutionScope;
import lang.MatchValue;
import lang.Types.Tuple;
interface TermExecuter extends BaseObject {
  function execute(term: Tuple, process: Process, scope: ExecutionScope, mailbox: List<MatchValue>): ExecutionResult;
}
