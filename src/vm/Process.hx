package vm;
import lang.MatchValue;
import core.BaseObject;
interface Process extends BaseObject {
  var parentProcess(get, set): Process;
  var childProcesses(get, null): Array<Process>;
  var status(get, null): ProcessStatus;
  function addChildProcess(process: Process): Void;
  function removeChildProcess(process: Process): Void;
  function execute(): Void;
  function receiveMessage(matchValue: MatchValue): Void;
  function setWaiting(): Void;
  function setStopped(): Void;
  function send(matchValue: MatchValue): Void;
}
