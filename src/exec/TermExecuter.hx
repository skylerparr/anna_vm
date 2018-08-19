package exec;
import lang.MatchValue;
import interp.ExecutionScope;
import haxe.ds.StringMap;
import lang.Types.Tuple;
import core.BaseObject;
interface TermExecuter extends BaseObject {
  function execute(term: Tuple, scope: ExecutionScope, mailbox: List<MatchValue>): Dynamic;
}
