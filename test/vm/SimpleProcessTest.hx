package vm;

import vm.Process;
import interp.DataStructureInterpreter;
import support.InterpSupport;
import core.ObjectCreator;
import exec.TermExecuter;
import interp.DefaultDataStructureInterpreter;
import interp.StringDecoder;
import interp.StringEncoder;
import interp.StringMapExecutionScope;
import lang.AtomSupport;
import lang.HashTableAtoms;
import lang.MatchType;
import lang.MatchValue;
import massive.munit.Assert;
import util.StackUtil;
import vm.ExecutionResult.ResultType;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
using lang.AtomSupport;

class SimpleProcessTest {

  private var process: SimpleProcess;
  private var termExecuter: TermExecuter;
  private var kernel: Kernel;
  private var interp: DataStructureInterpreter;
  private var emptyScope: StringMapExecutionScope;
  private var objectCreator: ObjectCreator;

  @BeforeClass
  public function beforeClass():Void {
    var atoms: HashTableAtoms = new HashTableAtoms();
    AtomSupport.atoms = atoms;
  }

  @AfterClass
  public function afterClass():Void {
    AtomSupport.atoms = null;
  }

  @Before
  public function setup():Void {
    interp = InterpSupport.getInterpreter();

    objectCreator = mock(ObjectCreator);
    termExecuter = mock(TermExecuter);
    kernel = mock(Kernel);

    emptyScope = new StringMapExecutionScope();
  }

  @After
  public function tearDown():Void {
    process = null;
  }

  @Test
  public function shouldAddSelfToScopeByDefault(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    Assert.areEqual(emptyScope.get("$currentProcess$"), process);
  }

  @Test
  public function shouldNotifyKernelToRemoveProcessIfNoMoreTermsToExecute(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var execResult: ExecutionResult = {type: ResultType.CONSTANT, value: {type: MatchType.CONSTANT, varName: null, value: 2}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    process.execute();
    kernel.endProcess(process).verify();
  }

  @Test
  public function shouldAddFunctionStack(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var block: MatchValue = interp.decode("{:__block__, {{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}, {:add, {:native, :\"lib.BasicMath\"}, {1, 1}}, {:add, {:native, :\"lib.BasicMath\"}, {1, 1}}}}", emptyScope);
    var execResult: ExecutionResult = {type: ResultType.PUSH_STACK, value: block};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    Assert.areEqual(1, StackUtil.length(cast process.stack));
  }

  @Test
  public function shouldPopFunctionStackIfAtTheEndOfTheStack(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var block: MatchValue = interp.decode("{:__block__, {{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}, {:add, {:native, :\"lib.BasicMath\"}, {1, 1}}, {:add, {:native, :\"lib.BasicMath\"}, {1, 1}}}}", emptyScope);
    var execResult: ExecutionResult = {type: ResultType.PUSH_STACK, value: block};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    termExecuter.reset();
    var execResult:ExecutionResult = {type: ResultType.CONSTANT, value: {type: MatchType.CONSTANT, varName: null, value: 2}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    process.execute();
    process.execute();
    process.execute();
    process.execute();
    process.execute();

    Assert.areEqual(0, StackUtil.length(cast process.stack));
    Assert.areEqual(ProcessStatus.STOPPED, process.status);
  }

  @Test
  public function shouldUpdateScopeVarsWithResult(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var execResult: ExecutionResult = {type: ResultType.CONSTANT, value: {type: MatchType.CONSTANT, varName: null, value: 2}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    Assert.areEqual(2, emptyScope.get("$result$").value);
  }

  @Test
  public function shouldPopTheStackBeforePushingTheStackIfAtTheEndOfTheStack(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var block: MatchValue = interp.decode("{:__block__, {{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}, {:add, {:native, :\"lib.BasicMath\"}, {1, 1}}, {:add, {:native, :\"lib.BasicMath\"}, {1, 1}}}}", emptyScope);
    var execResult: ExecutionResult = {type: ResultType.PUSH_STACK, value: block};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    termExecuter.reset();
    var execResult:ExecutionResult = {type: ResultType.CONSTANT, value: {type: MatchType.CONSTANT, varName: null, value: 2}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    process.execute();
    Assert.areEqual(1, StackUtil.length(cast process.stack));
  }

  @Test
  public function shouldAddToTheMailbox(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    process.receiveMessage({type: MatchType.CONSTANT, varName: null, value: 2});
    Assert.areEqual(process.mailbox.length, 1);
  }

  @Test
  public function shouldNotifyKernelIfErrorInProcess(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var execResult: ExecutionResult = {type: ResultType.ERROR, value: {type: MatchType.CONSTANT, varName: null, value: "Error"}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    Assert.areEqual(ProcessStatus.STOPPED, process.status);
    kernel.processError(process).verify();
  }

  @Test
  public function shouldDispose(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    process.dispose();
    Assert.isNull(process.executer);
    Assert.isNull(process.kernel);
    Assert.isNull(process.objectCreator);
    Assert.isNull(process.stack);
    Assert.isNull(process.mailbox);
    Assert.areEqual(ProcessStatus.DESTROYED, process.status);
  }

  @Test
  public function shouldSetProcessAsWaiting(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var execResult: ExecutionResult = {type: ResultType.CONSTANT, value: {type: MatchType.CONSTANT, varName: null, value: 2}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    process.setWaiting();
    Assert.areEqual(ProcessStatus.WAITING, process.status);
  }

  @Test
  public function shouldSetProcessAsStopped(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var execResult: ExecutionResult = {type: ResultType.CONSTANT, value: {type: MatchType.CONSTANT, varName: null, value: 2}};
    termExecuter.execute(cast any, process, cast any).returns(execResult);
    process.execute();
    process.setStopped();
    Assert.areEqual(ProcessStatus.STOPPED, process.status);
  }

  @Test
  public function shouldAddMatchValueToProcessMailbox() {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var data: MatchValue = interp.decode('{:foo, "bar"}', emptyScope);
    Assert.areEqual(process.mailbox.length, 0);
    process.send(data);
    Assert.areEqual(process.mailbox.length, 1);
  }

  @Test
  public function shouldAddChildProcess(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var child1: Process = mock(Process);
    var child2: Process = mock(Process);
    var child3: Process = mock(Process);

    process.addChildProcess(child1);
    process.addChildProcess(child2);
    process.addChildProcess(child3);

    Assert.areEqual(process.childProcesses.length, 3);
  }

  @Test
  public function shouldRemoveChildProcess(): Void {
    var process: SimpleProcess = createProcess(interp.decode("{:add, {:native, :\"lib.BasicMath\"}, {1, 1}}", emptyScope));
    var child1: Process = mock(Process);
    var child2: Process = mock(Process);
    var child3: Process = mock(Process);

    process.addChildProcess(child1);
    process.addChildProcess(child2);
    process.addChildProcess(child3);

    process.removeChildProcess(child1);
    process.removeChildProcess(child2);
    process.removeChildProcess(child3);

    Assert.areEqual(process.childProcesses.length, 0);
  }

  private inline function createProcess(matchValue: MatchValue): SimpleProcess {
    var process: SimpleProcess = new SimpleProcess();
    process.executer = termExecuter;
    process.kernel = kernel;
    process.objectCreator = objectCreator;
    objectCreator.createInstance(cast any).returns(emptyScope);
    process.init([matchValue, emptyScope]);
    return process;
  }
}