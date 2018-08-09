package exec;
import lang.Types.Tuple;
import core.BaseObject;
interface TermExecuter extends BaseObject {
  function execute(term: Tuple): Dynamic;
}
