package ;
import code.ApplicationCode;
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
import code.ApplicationCode.AccessModifier;

using lang.AtomSupport;

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
  @inject
  public var applicationCode: ApplicationCode;

  private var mainThread: Thread;

  public function new() {
  }

  private function onCreate():Void {
    mainThread = Thread.readMessage(true);

    var scope: ExecutionScope = objectCreator.createInstance(ExecutionScope);
    var block: MatchValue = interp.decode('{:__block__, {}}', scope);

    var blockDetails: Array<MatchValue> = block.value.value[1].value.value;
    for(i in 0...5) {
      var c: MatchValue = interp.decode('{:add, {:native, :\"lib.BasicMath\"}, {${i}, ${i}}}', scope);
      blockDetails.push(c);
    }
    var args: MatchValue = interp.decode('{arg1, arg2}', scope);
    applicationCode.define("Foo".atom(), "bar".atom(), AccessModifier.PUBLIC, args, block);

    var fun: MatchValue = interp.decode('{:Foo, {:anna, :bar}, {1, 2}}', scope);

    var process: Process = objectCreator.createInstance(Process, [], [fun, scope]);
    while(true) {
      process.execute();
    }
    mainThread.sendMessage(false);
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
