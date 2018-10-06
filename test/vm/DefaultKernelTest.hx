package vm;

import core.ProcessManager;
import lang.MatchValue;
import support.InterpSupport;
import interp.DataStructureInterpreter;
import interp.ExecutionScope;
import lang.HashTableAtoms;
import lang.AtomSupport;
import core.ObjectCreator;
import massive.munit.Assert;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
using lang.AtomSupport;

class DefaultKernelTest {

  private var kernel: DefaultKernel;
  private var objectCreator: ObjectCreator;
  private var processManager: ProcessManager;
  private var parentProcess: Process;
  private var scope: ExecutionScope;
  private var interp: DataStructureInterpreter;

  @BeforeClass
  public function beforeClass():Void {
    var atoms: HashTableAtoms = new HashTableAtoms();
    AtomSupport.atoms = atoms;
  }

  @AfterClass
  public function afterClass():Void  {
    AtomSupport.atoms = null;
  }

  @Before
  public function setup():Void {
    objectCreator = mock(ObjectCreator);
    interp = InterpSupport.getInterpreter();

    parentProcess = mock(Process);
    scope = mock(ExecutionScope);
    processManager = mock(ProcessManager);

    kernel = new DefaultKernel();
    kernel.objectCreator = objectCreator;
    kernel.processManager = processManager;
    kernel.init();
  }

  @After
  public function tearDown():Void {
    kernel.dispose();
    kernel = null;
    processManager = null;
  }

  @Test
  public function shouldSpawnNewProcess(): Void {
    var newProcess: Process = mock(Process);
    var fun: MatchValue = interp.decode('{:Foo, {:anna, :bar}, {1, 2}}', scope);
    processManager.startProcess(parentProcess, fun, scope).returns(newProcess);
    var p = kernel.spawnProcess(parentProcess, fun, scope);
    Assert.isNotNull(p);
    processManager.startProcess(parentProcess, fun, scope).verify();
  }

  @Test
  public function shouldTerminateProcess(): Void {
    var newProcess: Process = mock(Process);
    kernel.endProcess(newProcess);
    processManager.termProcess(newProcess).verify();
  }

}