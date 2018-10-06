package core;

import core.Scheduler;
import cpp.vm.Thread;
class CPPSchedulerManager implements SchedulerManager {

  @inject
  public var objectCreator: ObjectCreator;

  @inject
  public var processManager: ProcessManager;

  public var mainThread: Thread;

  public var schedulers: Array<Scheduler>;

  public function new() {
  }

  public function init(args:Array<Dynamic> = null):Void {
    schedulers = [];
    createSchedulers();
  }

  public function dispose():Void {
  }

  public function createSchedulers() {
    for(i in 0...8) {
      var scheduler: Scheduler = objectCreator.createInstance(Scheduler);
      schedulers.push(scheduler);
    }
  }
}