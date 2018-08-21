package ;
import lib.BasicMath;
import vm.Process;
import lang.MatchValue;
import lang.MatchData;
import interp.ExecutionScope;
import interp.DataStructureInterpreter;
import cpp.vm.Thread;
import core.BaseObject;
import core.ObjectCreator;
import core.InjectionSettings;
@IgnoreCover
class Main implements BaseObject {
  public static function main() {
    new InjectionSettings(function(objectCreator: ObjectCreator) {
        objectCreator.createInstance(Main);
    });
  }

  @inject
  public var interp: DataStructureInterpreter;
  @inject
  public var objectCreator: ObjectCreator;

  private var mainThread: Thread;

  public function new() {
  }

  private function onCreate():Void {
    mainThread = Thread.readMessage(true);

    var scope: ExecutionScope = objectCreator.createInstance(ExecutionScope);
    var matchValue: MatchValue = interp.decode("{:sleep, {:native, :Sys}, {100}}", scope);

    var process: Process = objectCreator.createInstance(Process, [], [matchValue, scope]);
    while(true) {
      process.execute();
      trace(scope.get("$result$"));
      Sys.sleep(1);
    }
  }

  public function init(args:Array<Dynamic> = null):Void {
    trace("VM started");
    var thread: Thread = Thread.create(onCreate);
    thread.sendMessage(Thread.current());
    var running: Bool = true;
    while(running) {
      running = Thread.readMessage(true);
    }
  }

  public function dispose():Void {
  }
}
