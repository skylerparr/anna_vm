package exec;

import interp.ExecutionScope;
import haxe.ds.StringMap;
import lang.MatchValue;
import interp.StringDecoder;
import interp.StringEncoder;
import interp.DefaultDataStructureInterpreter;
import interp.DataStructureInterpreter;
import lang.AtomSupport;
import lang.HashTableAtoms;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

class DefaultTermExecuterTest {

  private var termExecuter: DefaultTermExecuter;
  private var interp: DefaultDataStructureInterpreter;
  private var encoder: StringEncoder;
  private var decoder: StringDecoder;

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
    interp = new DefaultDataStructureInterpreter();
    interp.stringDecoder = decoder;
    interp.stringEncoder = encoder;

    termExecuter = new DefaultTermExecuter();
    termExecuter.init();
  }

  @After
  public function tearDown():Void {
    termExecuter.dispose();
    termExecuter = null;
  }

  @Test
  public function shouldInvokeANativeFunction():Void {
    var scope: ExecutionScope = mock(ExecutionScope);
    var left: MatchValue = interp.decode("{:add, {:native, :\"lib.Kernel\"}, {1, 1}}", scope);
    var value: Dynamic = termExecuter.execute(left.value, scope);
    Assert.areEqual(value, 2);

    var left: MatchValue = interp.decode("{:subtract, {:native, :\"lib.Kernel\"}, {1, 1}}", scope);
    var value: Dynamic = termExecuter.execute(left.value, scope);
    Assert.areEqual(value, 0);

    var left: MatchValue = interp.decode("{:multiply, {:native, :\"lib.Kernel\"}, {9, 9}}", scope);
    var value: Dynamic = termExecuter.execute(left.value, scope);
    Assert.areEqual(value, 81);

    var left: MatchValue = interp.decode("{:divide, {:native, :\"lib.Kernel\"}, {81, 9}}", scope);
    var value: Dynamic = termExecuter.execute(left.value, scope);
    Assert.areEqual(value, 9);
  }
}