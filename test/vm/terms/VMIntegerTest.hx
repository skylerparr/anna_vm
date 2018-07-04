package vm.terms;

import massive.munit.Assert;

class VMIntegerTest {

  @Before
  public function setup():Void {
  }

  @After
  public function tearDown():Void {
  }

  @Test
  public function shouldReturnIntegerValue():Void {
    var val: Int = cast(new VMInteger(10).eval(), Int);
    Assert.areEqual(val, 10);
  }
}