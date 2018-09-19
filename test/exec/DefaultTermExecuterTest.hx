package exec;

import vm.Process;
import interp.DefaultDataStructureInterpreter;
import interp.ExecutionScope;
import interp.StringDecoder;
import interp.StringEncoder;
import lang.AtomSupport;
import lang.HashTableAtoms;
import lang.MatchValue;
import massive.munit.Assert;
import vm.ExecutionResult;
import vm.Kernel;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
using lang.AtomSupport;

class DefaultTermExecuterTest {

  private var termExecuter: DefaultTermExecuter;
  private var interp: DefaultDataStructureInterpreter;
  private var encoder: StringEncoder;
  private var decoder: StringDecoder;
  private var kernel: Kernel;
  private var process: Process;

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

    kernel = mock(Kernel);
    process = mock(Process);

    termExecuter = new DefaultTermExecuter();
    termExecuter.kernel = kernel;
    termExecuter.init();
  }

  @After
  public function tearDown():Void {
    termExecuter = null;
  }

  @Test
  public function shouldInvokeANativeFunction():Void {
    var mailbox: List<MatchValue> = new List<MatchValue>();

    var scope: ExecutionScope = mock(ExecutionScope);
    var left: MatchValue = interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.value.value, 2);

    var left: MatchValue = interp.decode("{:subtract, {:native, :\"lib.BasicMath\"}, {1, 1}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.value.value, 0);

    var left: MatchValue = interp.decode("{:multiply, {:native, :\"lib.BasicMath\"}, {9, 9}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.value.value, 81);

    var left: MatchValue = interp.decode("{:divide, {:native, :\"lib.BasicMath\"}, {81, 9}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.value.value, 9);
  }

  @Test
  public function shouldInvokeNativeFunctionWithVariables(): Void {
    var mailbox: List<MatchValue> = new List<MatchValue>();

    var scope: ExecutionScope = mock(ExecutionScope);
    scope.get("foo").returns(5);
    scope.get("bar").returns(7);
    var left: MatchValue = interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {foo, bar}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.value.value, 12);

    scope.get("anna").returns(8);
    var left: MatchValue = interp.decode("{:subtract, {:native, :\"lib.BasicMath\"}, {20, anna}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.value.value, 12);
  }

  @Test
  public function shouldInvokeANonNativeFunction(): Void {
    var mailbox: List<MatchValue> = new List<MatchValue>();
    var scope: ExecutionScope = mock(ExecutionScope);

    var kernelResult: MatchValue = interp.decode("{:__block, {}}", scope);
    kernel.apply(process, "Foo".atom(), "bar".atom(), cast any).returns(kernelResult);

    var left: MatchValue = interp.decode("{:Foo, {:anna, :bar}, {}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.type, ResultType.PUSH_STACK);
    Assert.areEqual(value.value, kernelResult);
  }

  @Test
  public function shouldHandleErrorANonNativeFunction(): Void {
    var mailbox: List<MatchValue> = new List<MatchValue>();
    var scope: ExecutionScope = mock(ExecutionScope);

    var kernelResult: MatchValue = interp.decode("{:__block, {}}", scope);
    kernel.apply(process, "Foo".atom(), "bar".atom(), cast any).throws("Bad Match");

    var scope: ExecutionScope = mock(ExecutionScope);
    var left: MatchValue = interp.decode("{:Foo, {:anna, :bar}, {}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.type, ResultType.ERROR);
    Assert.areEqual(value.value.value, "Bad Match");
  }

  @Test
  public function shouldReturnErrorOnError(): Void {
    var mailbox: List<MatchValue> = new List<MatchValue>();
    var scope: ExecutionScope = mock(ExecutionScope);

    var left: MatchValue = interp.decode("{:error, {:native, :\"lib.BasicMath\"}, {81, 9}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.type, ResultType.ERROR);
    Assert.isNotNull(value.value);

    var left: MatchValue = interp.decode("{:kdasfjlsdf, {:native, :\"lib.BasicMath\"}, {81, 9}}", scope);
    var value: ExecutionResult = termExecuter.execute(left.value, process, scope);
    Assert.areEqual(value.type, ResultType.ERROR);
    Assert.isNotNull(value.value);
  }

}