package ;
import core.ObjectCreator;
import core.InjectionSettings;
@IgnoreCover
class Main {
  public static function main() {
    new InjectionSettings(function(objectCreator: ObjectCreator) {
        objectCreator.createInstance(Main);
    });
  }

  public function new() {
    trace("VM starting");
  }
}
