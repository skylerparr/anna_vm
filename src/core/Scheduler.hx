package core;

import vm.Process;
interface Scheduler extends BaseObject {
  function start(process: Process, onFinished: Scheduler->Void): Void;
}