package vm.terms;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


class VMAtomTest {
  @Before
  public function setup():Void {
  }

  @After
  public function tearDown():Void {
  }

  @Test
  public function shouldReturnAtomValue():Void {
    var val:String = cast(new VMAtom("foo").eval(), String);
    Assert.areEqual(val, "foo");
  }
}