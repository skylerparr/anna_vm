package lang;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


class HashTableAtomsTest {

  private var atoms: HashTableAtoms;

  @Before
  public function setup():Void {
    atoms = new HashTableAtoms();
  }

  @After
  public function tearDown():Void {
    atoms = null;
  }

  @Test
  public function shouldCreateTheAtomIfItDoesntExist():Void {
    var key: String = "foo";
    Assert.isFalse(atoms.getMap().exists(key));
    Assert.isNotNull(atoms.get(key));
    Assert.areEqual(atoms.get(key), atoms.getMap().get(key));
  }
}