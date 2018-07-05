package vm.terms;

import massive.munit.Assert;


class VMUTF8AtomTest {
  @Before
  public function setup():Void {
  }

  @After
  public function tearDown():Void {
  }

  @Test
  public function shouldReturnUTF8AtomValue():Void {
    var val:String = cast(new VMUTF8Atom("∆ø").eval(), String);
    Assert.areEqual(val, "∆ø");
  }
}