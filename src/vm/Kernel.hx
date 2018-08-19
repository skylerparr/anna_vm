package vm;

import core.BaseObject;

interface Kernel extends BaseObject {
  function endProcess(process: Process): Void;
  function processWaiting(process: Process): Void;
  function processError(process: Process): Void;
}