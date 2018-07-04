package core;
import error.Logger;
import error.TraceLogger;
import minject.Injector;

@IgnoreCover
class InjectionSettings {
  public var injector: Injector = new Injector();

  public function new(complete: ObjectCreator->Void) {
    ObjectFactory.injector = injector;

    var objectFactory: ObjectFactory = new ObjectFactory();
    injector.mapValue(ObjectCreator, objectFactory);

    injector.mapSingletonOf(Logger, TraceLogger);

    complete(objectFactory);
  }
}
