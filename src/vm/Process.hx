package vm;
import lang.MatchValue;
import core.BaseObject;
interface Process extends BaseObject {
  function execute(): Void;
  function receiveMessage(matchValue: MatchValue): Void;
  function setWaiting(): Void;
}
