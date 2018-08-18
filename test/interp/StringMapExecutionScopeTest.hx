package interp;

import lang.AtomSupport;
import lang.HashTableAtoms;
import massive.munit.Assert;

using lang.AtomSupport;

class StringMapExecutionScopeTest {

  private var scope: StringMapExecutionScope;

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
    scope = new StringMapExecutionScope();
    scope.init();
  }

  @After
  public function tearDown():Void {
    scope = null;
  }

  @Test
  public function shouldAddVariableToExecutionScope(): Void {
    var varName: String = "foo";
    scope.put(varName, "bar".atom());
    Assert.areEqual("bar".atom(), scope.get(varName));
  }

  @Test
  public function shouldReturnNilAtomIfVarNotFound(): Void {
    var varName: String = "foo";
    Assert.areEqual("nil".atom(), scope.get(varName));
  }

  @Test
  public function shouldDispose(): Void {
    scope.dispose();
    Assert.isNull(scope.varMap);
  }
}