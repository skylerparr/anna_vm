package core;
import lang.AtomSupport;
import lang.HashTableAtoms;
import lang.Atoms;
import interp.StringEncoder;
import interp.StringDecoder;
import exec.DefaultTermExecuter;
import exec.TermExecuter;
import interp.StringMapExecutionScope;
import interp.ExecutionScope;
import interp.DefaultDataStructureInterpreter;
import interp.DataStructureInterpreter;
import matcher.Matcher;
import matcher.DefaultMatcher;
import vm.DefaultKernel;
import vm.Kernel;
import vm.SimpleProcess;
import vm.Process;
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

    var atoms: HashTableAtoms = new HashTableAtoms();
    AtomSupport.atoms = atoms;

    injector.mapValue(Atoms, atoms);
    injector.mapSingletonOf(Logger, TraceLogger);
    injector.mapClass(Process, SimpleProcess);
    injector.mapSingletonOf(Kernel, DefaultKernel);
    injector.mapSingletonOf(Matcher, DefaultMatcher);
    injector.mapSingletonOf(StringDecoder, StringDecoder);
    injector.mapSingletonOf(StringEncoder, StringEncoder);
    injector.mapSingletonOf(DataStructureInterpreter, DefaultDataStructureInterpreter);
    injector.mapClass(ExecutionScope, StringMapExecutionScope);
    injector.mapClass(TermExecuter, DefaultTermExecuter);

    complete(objectFactory);
  }
}
