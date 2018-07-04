package vm.terms;

import massive.munit.Assert;

class VMFloatTest {

  @Before
  public function setup():Void {
  }

  @After
  public function tearDown():Void {
  }

  @Test
  public function shouldReturnFloatValue():Void {
    var val:Float = cast(new VMFloat(21.43343).eval(), Float);
    Assert.areEqual(val, 21.43343);
  }
}