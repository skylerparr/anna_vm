package core;

import core.Scheduler;
import cpp.vm.Thread;
class CPPSchedulerManager implements SchedulerManager {

  @inject
  public var objectCreator: ObjectCreator;

  public var mainThread: Thread;

  public var schedulers: Array<Scheduler>;

  public function new() {
  }

  public function init(args:Array<Dynamic> = null):Void {
    schedulers = [];

    var thread: Thread = Thread.create(onSchedulerCreated);

    thread.sendMessage(Thread.current());
    var running: Bool = true;
    while(running) {
      running = Thread.readMessage(true);
    }
  }

  public function dispose():Void {
  }

  public function onSchedulerCreated() {
    mainThread = Thread.readMessage(true);

    for(i in 0...8) {
      var scheduler: Scheduler = objectCreator.createInstance(Scheduler);
      schedulers.push(scheduler);
    }
  }
}