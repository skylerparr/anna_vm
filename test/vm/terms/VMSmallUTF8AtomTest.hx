package vm.terms;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


class VMSmallUTF8AtomTest {
  @Before
  public function setup():Void {
  }

  @After
  public function tearDown():Void {
  }

  @Test
  public function shouldReturnUTF8AtomValue():Void {
    var val:String = cast(new VMSmallUTF8Atom("∆").eval(), String);
    Assert.areEqual(val, "∆");
  }
}