package core;

import vm.ProcessStatus;
import vm.Process;
import vm.SimpleProcess;
import lang.MatchValue;
import support.InterpSupport;
import interp.DataStructureInterpreter;
import interp.ExecutionScope;
import vm.Process;
import lang.HashTableAtoms;
import lang.AtomSupport;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
using lang.AtomSupport;

class ThreadSafeProcessManagerTest {

  private var processManager: ThreadSafeProcessManager;
  private var objectCreator: ObjectCreator;
  private var scope: ExecutionScope;
  private var interp: DataStructureInterpreter;
  private var parentProcess: Process;
  private var fun: MatchValue;
  private var createdProcess: Process;

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
    objectCreator = mock(ObjectCreator);
    scope = mock(ExecutionScope);
    interp = InterpSupport.getInterpreter();

    processManager = new ThreadSafeProcessManager();
    processManager.objectCreator = objectCreator;
    processManager.init();

    parentProcess = mock(Process);
    createdProcess = mock(Process);
    fun = interp.decode("{}", scope);
    objectCreator.createInstance(Process, cast any, cast any).returns(createdProcess);
  }

  @After
  public function tearDown():Void {
    processManager = null;
    objectCreator = null;
    scope = null;
  }

  @Test
  public function shouldStartAProcess(): Void {
    var process: Process = processManager.startProcess(parentProcess, fun, scope);
    Assert.areEqual(processManager.allProcesses().length, 1);
    Assert.areEqual(process, createdProcess);
  }

  @Test
  public function shouldRemoveProcessFromQueue(): Void {
    var process1: Process = mock(Process);
    objectCreator.createInstance(Process, cast any, cast any).returns(process1);

    processManager.startProcess(parentProcess, fun, scope);
    processManager.startProcess(parentProcess, fun, scope);

    Assert.areEqual(processManager.allProcesses().length, 2);

    Assert.areEqual(processManager.getNext(), process1);
    Assert.areEqual(processManager.getNext(), process1);
    Assert.areEqual(processManager.getNext(), process1);
  }

  @Test
  public function shouldRemoveProcessFromQueueWhenTerminatingProcess(): Void {
    processManager.startProcess(parentProcess, fun, scope);
    Assert.areEqual(processManager.allProcesses().length, 1);

    Assert.areEqual(processManager.getNext(), createdProcess);
    Assert.areEqual(processManager.getNext(), createdProcess);

    processManager.termProcess(createdProcess);
    Assert.isNull(processManager.getNext());
  }

  @Test
  public function shouldNotTerminateChildProcessesWhenTerminatingProcess(): Void {
    fun = interp.decode("{}", scope);

    objectCreator.reset();
    parentProcess = new SimpleProcess();
    parentProcess.init([fun, scope]);

    var p1: SimpleProcess = new SimpleProcess();
    p1.init([fun, scope]);
    var p2: SimpleProcess = new SimpleProcess();
    p2.init([fun, scope]);
    var p3: SimpleProcess = new SimpleProcess();
    p3.init([fun, scope]);
    objectCreator.createInstance(Process, cast any, cast any).returns(p1);
    objectCreator.createInstance(Process, cast any, cast any).returns(p2);
    objectCreator.createInstance(Process, cast any, cast any).returns(p3);

    processManager.startProcess(parentProcess, fun, scope);
    processManager.startProcess(parentProcess, fun, scope);
    processManager.startProcess(parentProcess, fun, scope);

    processManager.termProcess(parentProcess);

    Assert.areEqual(parentProcess.status, ProcessStatus.STOPPED);
    Assert.areEqual(p1.status, ProcessStatus.RUNNING);
    Assert.areEqual(p2.status, ProcessStatus.RUNNING);
    Assert.areEqual(p3.status, ProcessStatus.RUNNING);
    Assert.areEqual(processManager.allProcesses().length, 3);
  }

  @Test
  public function shouldTerminateChildProcessesWhenTerminatingProcess(): Void {
    fun = interp.decode("{}", scope);

    objectCreator.reset();
    parentProcess = new SimpleProcess();
    parentProcess.init([fun, scope]);

    var p1: SimpleProcess = new SimpleProcess();
    p1.init([fun, scope]);
    var p2: SimpleProcess = new SimpleProcess();
    p2.init([fun, scope]);
    var p3: SimpleProcess = new SimpleProcess();
    p3.init([fun, scope]);
    objectCreator.createInstance(Process, cast any, cast any).returns(p1);
    objectCreator.createInstance(Process, cast any, cast any).returns(p2);
    objectCreator.createInstance(Process, cast any, cast any).returns(p3);

    processManager.startProcess(parentProcess, fun, scope);
    processManager.startProcess(parentProcess, fun, scope);
    processManager.startProcess(parentProcess, fun, scope);

    processManager.killProcess(parentProcess);

    Assert.areEqual(parentProcess.status, ProcessStatus.STOPPED);
    Assert.areEqual(p1.status, ProcessStatus.STOPPED);
    Assert.areEqual(p2.status, ProcessStatus.STOPPED);
    Assert.areEqual(p3.status, ProcessStatus.STOPPED);

    Assert.areEqual(processManager.allProcesses().length, 0);
  }

  @Test
  public function shouldDispose(): Void {
    processManager.dispose();
    Assert.isNull(processManager.processess);
    Assert.isNull(processManager.objectCreator);
  }
}