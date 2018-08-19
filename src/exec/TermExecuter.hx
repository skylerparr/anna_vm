package exec;
import vm.ExecutionResult;
import core.BaseObject;
import interp.ExecutionScope;
import lang.MatchValue;
import lang.Types.Tuple;
interface TermExecuter extends BaseObject {
  function execute(term: Tuple, scope: ExecutionScope, mailbox: List<MatchValue>): ExecutionResult;
}
