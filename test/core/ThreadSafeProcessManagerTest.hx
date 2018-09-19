package core;

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
    processManager = new ThreadSafeProcessManager();
    processManager.init();
  }

  @After
  public function tearDown():Void {
    processManager = null;
  }

  @Test
  public function shouldStoreAProcess(): Void {
    var process1: Process = mock(Process);
    var process2: Process = mock(Process);
    processManager.storeProcess(process1);
    processManager.storeProcess(process2);

    Assert.areEqual(processManager.allProcesses().length, 2);
  }

  @Test
  public function shouldRemoveProcessFromQueue(): Void {
    var process1: Process = mock(Process);
    processManager.storeProcess(process1);

    Assert.areEqual(processManager.getNext(), process1);
    Assert.areEqual(processManager.getNext(), process1);
    Assert.areEqual(processManager.getNext(), process1);
  }

  @Test
  public function shouldRemoveProcessFromQueueWhenKillingProcess(): Void {
    var process1: Process = mock(Process);
    processManager.storeProcess(process1);

    Assert.areEqual(processManager.getNext(), process1);
    Assert.areEqual(processManager.getNext(), process1);

    processManager.killProcess(process1);
    Assert.isNull(processManager.getNext());
  }

  @Test
  public function shouldDispose(): Void {
    processManager.dispose();
    Assert.isNull(processManager.processess);
  }
}