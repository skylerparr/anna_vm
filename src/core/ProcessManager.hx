package core;
import interp.ExecutionScope;
import lang.MatchValue;
import vm.Process;
interface ProcessManager extends BaseObject {
  function startProcess(parentProcess: Process, fun: MatchValue, scope: ExecutionScope): Process;
  function getNext(): Process;
  /**
   * When terminating a process, it is set to stopped, but none of the child
   * processes are stopped.
   */
  function termProcess(process: Process): Void;
  /**
   * When kill a process, it is set to stopped, then all of the
   * child processes are stopped
   */
  function killProcess(process: Process): Void;
}
