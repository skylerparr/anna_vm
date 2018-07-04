package vm.terms;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


class VMStringTest {

  @Before
  public function setup():Void {
  }

  @After
  public function tearDown():Void {
  }

  @Test
  public function shouldReturnStringValue():Void {
    var val: String = cast(new VMString("Foo").eval(), String);
    Assert.areEqual(val, "Foo");
  }
}