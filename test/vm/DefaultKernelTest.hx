package vm;

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

    kernel = new DefaultKernel();
    kernel.objectCreator = objectCreator;
    kernel.init();
  }

  @After
  public function tearDown():Void {
    kernel.dispose();
    kernel = null;
  }

  @Test
  public function shouldSpawnNewProcess(): Void {
    var newProcess: Process = mock(Process);
    objectCreator.createInstance(cast any, cast any, cast any).returns(newProcess);
    var fun: MatchValue = interp.decode('{:Foo, {:anna, :bar}, {1, 2}}', scope);
    var p = kernel.spawnProcess(parentProcess, fun, scope);
    Assert.isNotNull(p);
  }

}