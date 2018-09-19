package vm;
import lang.MatchValue;
import core.BaseObject;
interface Process extends BaseObject {
  var parentProcess(get, set): Process;
  function execute(): Void;
  function receiveMessage(matchValue: MatchValue): Void;
  function setWaiting(): Void;
  function send(matchValue: MatchValue): Void;
}
