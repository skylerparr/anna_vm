package vm;

import vm.terms.VMUTF8Atom;
import vm.terms.VMAtom;
import vm.terms.VMString;
import vm.terms.VMFloat;
import error.InvalidByteCodeError;
import vm.terms.VMInteger;
import vm.Term;
import const.ByteCodes;
import haxe.io.Bytes;
import massive.munit.Assert;


class DefaultByteCodeInterpreterTest {

  private var interp: DefaultByteCodeInterpreter;

  @Before
  public function setup():Void {
    interp = new DefaultByteCodeInterpreter();
  }

  @After
  public function tearDown():Void {
    interp = null;
  }

  @Test
  public function shouldThrowInvalidByteCodeExceptionIfFirstBytesAreNotStart(): Void {
    var bytes: Bytes = Bytes.alloc(3);
    bytes.setInt32(0, 23092);
    try {
      interp.interpret(bytes);
      Assert.isTrue(false);
    } catch(e: InvalidByteCodeError) {
      Assert.isTrue(true);
    }
  }

  @Test
  public function shouldInterpretBytesToIntegerTerm(): Void {
    var bytes: Bytes = Bytes.alloc(3);
    var pos: Int = 0;
    bytes.set(pos++, ByteCodes.START);
    bytes.set(pos++, ByteCodes.INTEGER);
    bytes.setInt32(pos++, 4);
    var term: Term = interp.interpret(bytes);
    Assert.areEqual(Type.getClass(term), VMInteger);
    Assert.areEqual(term.eval(), 4);
  }

  @Test
  public function shouldInterpretBytesToVMFloatTerm(): Void {
    var bytes: Bytes = Bytes.alloc(10);
    var pos: Int = 0;
    bytes.set(pos++, ByteCodes.START);
    bytes.set(pos++, ByteCodes.FLOAT);
    bytes.setFloat(pos++, 1.0);
    var term: Term = interp.interpret(bytes);
    Assert.areEqual(Type.getClass(term), VMFloat);
    Assert.areEqual(term.eval(), 1.0);
  }

  @Test
  public function shouldInterpretBytesToVMStringTerm(): Void {
    var bytes: Bytes = Bytes.alloc(7);
    var pos: Int = 0;
    bytes.set(pos++, ByteCodes.START);
    bytes.set(pos++, ByteCodes.STRING);
    bytes.setInt32(pos, 1);
    bytes.set(6, 97);
    var term: Term = interp.interpret(bytes);
    Assert.areEqual(Type.getClass(term), VMString);
    Assert.areEqual(term.eval(), "a");
  }

  @Test
  public function shouldInterpretBytesToVMAtomTerm(): Void {
    var bytes: Bytes = Bytes.alloc(5);
    var pos: Int = 0;
    bytes.set(pos++, ByteCodes.START);
    bytes.set(pos++, ByteCodes.ATOM);
    bytes.set(pos++, 0);
    bytes.set(pos++, 1);
    bytes.set(pos, 97);
    var term: Term = interp.interpret(bytes);
    Assert.areEqual(Type.getClass(term), VMAtom);
    Assert.areEqual(term.eval(), "a");
  }

  @Test
  public function shouldInterpretBytesToVMUTF8AtomTerm(): Void {
    var bytes: Bytes = Bytes.alloc(6);
    var pos: Int = 0;
    bytes.set(pos++, ByteCodes.START);
    bytes.set(pos++, ByteCodes.UTF8_ATOM);
    bytes.set(pos++, 3);
    bytes.set(pos++, 226);
    bytes.set(pos++, 136);
    bytes.set(pos++, 134);
    var term: Term = interp.interpret(bytes);
    Assert.areEqual(Type.getClass(term), VMUTF8Atom);
    Assert.areEqual(term.eval(), "∆");
  }
}