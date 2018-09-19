package core;
import vm.Process;
interface ProcessManager extends BaseObject {
  function storeProcess(process: Process): Void;
  function getNext(): Process;
  function killProcess(process: Process): Void;
}
